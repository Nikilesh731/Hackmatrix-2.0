const fs = require('fs');
const path = require('path');

// Directories to include
const INCLUDE_DIRS = [
  'backend',
  'mobile_app', 
  'shared_contracts',
  'docs',
  'scripts'
];

// Directories/files to exclude
const EXCLUDE = [
  'node_modules',
  '.git',
  '.dart_tool',
  'build',
  'dist',
  '.DS_Store',
  '*.log'
];

function shouldExclude(name) {
  return EXCLUDE.some(pattern => {
    if (pattern.includes('*')) {
      const regex = new RegExp(pattern.replace('*', '.*'));
      return regex.test(name);
    }
    return name === pattern;
  });
}

function getDirectoryStructure(dirPath, prefix = '', isLast = true) {
  const items = fs.readdirSync(dirPath)
    .filter(item => !shouldExclude(item))
    .sort((a, b) => {
      // Sort directories first, then files
      const aPath = path.join(dirPath, a);
      const bPath = path.join(dirPath, b);
      const aIsDir = fs.statSync(aPath).isDirectory();
      const bIsDir = fs.statSync(bPath).isDirectory();
      
      if (aIsDir && !bIsDir) return -1;
      if (!aIsDir && bIsDir) return 1;
      return a.localeCompare(b);
    });

  let result = '';
  
  items.forEach((item, index) => {
    const itemPath = path.join(dirPath, item);
    const isDir = fs.statSync(itemPath).isDirectory();
    const isLastItem = index === items.length - 1;
    
    // Add the current item
    const connector = isLastItem ? '└── ' : '├── ';
    result += prefix + connector + item + (isDir ? '/' : '') + '\n';
    
    // Recursively add subdirectories
    if (isDir) {
      const newPrefix = prefix + (isLastItem ? '    ' : '│   ');
      result += getDirectoryStructure(itemPath, newPrefix, isLastItem);
    }
  });
  
  return result;
}

function generateRepoMap() {
  const projectRoot = process.cwd();
  const projectName = path.basename(projectRoot);
  
  let content = `${projectName}/\n`;
  
  // Add included directories
  INCLUDE_DIRS.forEach((dir, index) => {
    const dirPath = path.join(projectRoot, dir);
    if (fs.existsSync(dirPath)) {
      const isLast = index === INCLUDE_DIRS.length - 1;
      const connector = isLast ? '└── ' : '├── ';
      content += connector + dir + '/\n';
      
      const newPrefix = isLast ? '    ' : '│   ';
      content += getDirectoryStructure(dirPath, newPrefix, isLast);
    }
  });
  
  // Write to REPO_MAP.md
  const outputPath = path.join(projectRoot, 'REPO_MAP.md');
  fs.writeFileSync(outputPath, content);
  
  console.log('REPO_MAP.md created/updated');
  return content;
}

// Run the generator
if (require.main === module) {
  generateRepoMap();
}

module.exports = { generateRepoMap };
