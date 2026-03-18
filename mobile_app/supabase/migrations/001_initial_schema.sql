-- Create UUID extension if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create patients table
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name TEXT NOT NULL,
    age INTEGER,
    gender TEXT,
    phone TEXT,
    address TEXT,
    blood_group TEXT,
    allergies TEXT,
    chronic_conditions TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create doctor_profiles table
CREATE TABLE IF NOT EXISTS doctor_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    specialization TEXT,
    hospital_name TEXT,
    registration_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create specialist_directory table
CREATE TABLE IF NOT EXISTS specialist_directory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_name TEXT NOT NULL,
    specialty TEXT,
    department TEXT,
    hospital_name TEXT,
    phone TEXT,
    email TEXT,
    availability_label TEXT,
    location TEXT,
    is_active BOOLEAN DEFAULT true
);

-- Create patient_queue table
CREATE TABLE IF NOT EXISTS patient_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    assigned_doctor_id UUID REFERENCES doctor_profiles(id) ON DELETE SET NULL,
    queue_status TEXT NOT NULL DEFAULT 'waiting',
    priority_label TEXT DEFAULT 'normal',
    token_number INTEGER,
    reason_for_visit TEXT,
    scheduled_for TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create consultations table
CREATE TABLE IF NOT EXISTS consultations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID REFERENCES doctor_profiles(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    queue_item_id UUID REFERENCES patient_queue(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'in_progress',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    final_transcript TEXT,
    soap_subjective TEXT,
    soap_objective TEXT,
    soap_assessment TEXT,
    soap_plan TEXT,
    structured_extraction JSONB,
    specialist_recommendations JSONB,
    medication_suggestions JSONB,
    confirmed_medications JSONB,
    prescription_payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients(phone);
CREATE INDEX IF NOT EXISTS idx_doctor_profiles_auth_id ON doctor_profiles(auth_id);
CREATE INDEX IF NOT EXISTS idx_patient_queue_patient_id ON patient_queue(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_queue_doctor_id ON patient_queue(assigned_doctor_id);
CREATE INDEX IF NOT EXISTS idx_patient_queue_status ON patient_queue(queue_status);
CREATE INDEX IF NOT EXISTS idx_consultations_doctor_id ON consultations(doctor_id);
CREATE INDEX IF NOT EXISTS idx_consultations_patient_id ON consultations(patient_id);
CREATE INDEX IF NOT EXISTS idx_consultations_status ON consultations(status);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_doctor_profiles_updated_at BEFORE UPDATE ON doctor_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_patient_queue_updated_at BEFORE UPDATE ON patient_queue
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) policies
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE specialist_directory ENABLE ROW LEVEL SECURITY;

-- Policies for patients table
CREATE POLICY "Users can view their own patients" ON patients
    FOR SELECT USING (true); -- In a real app, this would be more restrictive

CREATE POLICY "Doctors can insert patients" ON patients
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own patients" ON patients
    FOR UPDATE USING (true);

-- Policies for doctor_profiles table
CREATE POLICY "Users can view doctor profiles" ON doctor_profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own doctor profile" ON doctor_profiles
    FOR INSERT WITH CHECK (auth_id = auth.uid());

CREATE POLICY "Users can update their own doctor profile" ON doctor_profiles
    FOR UPDATE USING (auth_id = auth.uid());

-- Policies for patient_queue table
CREATE POLICY "Doctors can view queue items" ON patient_queue
    FOR SELECT USING (assigned_doctor_id IN (SELECT id FROM doctor_profiles WHERE auth_id = auth.uid()));

CREATE POLICY "Doctors can insert queue items" ON patient_queue
    FOR INSERT WITH CHECK (assigned_doctor_id IN (SELECT id FROM doctor_profiles WHERE auth_id = auth.uid()));

CREATE POLICY "Doctors can update queue items" ON patient_queue
    FOR UPDATE USING (assigned_doctor_id IN (SELECT id FROM doctor_profiles WHERE auth_id = auth.uid()));

-- Policies for consultations table
CREATE POLICY "Doctors can view their consultations" ON consultations
    FOR SELECT USING (doctor_id IN (SELECT id FROM doctor_profiles WHERE auth_id = auth.uid()));

CREATE POLICY "Doctors can insert consultations" ON consultations
    FOR INSERT WITH CHECK (doctor_id IN (SELECT id FROM doctor_profiles WHERE auth_id = auth.uid()));

CREATE POLICY "Doctors can update consultations" ON consultations
    FOR UPDATE USING (doctor_id IN (SELECT id FROM doctor_profiles WHERE auth_id = auth.uid()));

-- Policies for specialist_directory (read-only for authenticated users)
CREATE POLICY "Authenticated users can view specialists" ON specialist_directory
    FOR SELECT USING (auth.role() = 'authenticated');

-- Insert sample data for testing
INSERT INTO specialist_directory (doctor_name, specialty, department, hospital_name, phone, email, availability_label, location) VALUES
('Dr. Sarah Johnson', 'Cardiology', 'Heart Center', 'City General Hospital', '+1-555-0101', 'sarah.j@hospital.com', 'Available', 'Floor 3, Room 301'),
('Dr. Michael Chen', 'Neurology', 'Neuro Science', 'City General Hospital', '+1-555-0102', 'michael.c@hospital.com', 'Available', 'Floor 4, Room 402'),
('Dr. Emily Davis', 'Pediatrics', 'Child Care', 'City General Hospital', '+1-555-0103', 'emily.d@hospital.com', 'On Call', 'Floor 2, Room 203'),
('Dr. Robert Wilson', 'Orthopedics', 'Bone & Joint', 'City General Hospital', '+1-555-0104', 'robert.w@hospital.com', 'Available', 'Floor 5, Room 505'),
('Dr. Lisa Anderson', 'General Medicine', 'Primary Care', 'City General Hospital', '+1-555-0105', 'lisa.a@hospital.com', 'Available', 'Floor 1, Room 101');
