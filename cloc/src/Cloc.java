import java.io.*;
import java.nio.file.*;
import java.util.*;

public class Cloc {

    public static class FileStats {
        public int codeLines = 0;
        public int commentLines = 0;
        public int blankLines = 0;

        public void add(FileStats other) {
            this.codeLines += other.codeLines;
            this.commentLines += other.commentLines;
            this.blankLines += other.blankLines;
        }

        @Override
        public String toString() {
            return String.format("Code Lines: %d, Comment Lines: %d, Blank Lines: %d", codeLines, commentLines, blankLines);
        }
    }

    public static void main(String[] args) {
        
        // Help menu
        if (args.length != 1 || args[0].equals("-h") || args[0].equals("--help")) {
            System.out.println("Usage: java Cloc <file or directory path>");
            return;
        }
        

        // Get the path (dir or single file both ok)
        Path path = Paths.get(args[0]);

        // Make sure the file or directory exists
        if (!Files.exists(path)) {
            System.out.println("File or directory does not exist.");
            return;
        }
        
        // If so, we will create a new FileStats object to store the total statistics
        FileStats totalStats = new FileStats();
        
        // Recursively process the directory or a single file
        try {
            if (Files.isDirectory(path)) {
                // 递归处理目录
                Files.walk(path).filter(Files::isRegularFile).forEach(file -> {
                    
                    // If this is a java code file
                    if (!file.toString().endsWith(".java")) {
                        return;
                    }
                    
                    try {
                        FileStats stats = processFile(file);
                        System.out.println(file + ": " + stats);
                        totalStats.add(stats);
                    } catch (IOException e) {
                        System.out.println("Error reading file: " + file);
                    }
                });
            } else {
                // 处理单个文件
                FileStats stats = processFile(path);
                System.out.println(path + ": " + stats);
                totalStats.add(stats);
            }

            // 输出总计
            System.out.println("\nTotal Stats: " + totalStats);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static FileStats processFile(Path file) throws IOException {
        FileStats stats = new FileStats();
        boolean blockComment = false; // 标记块注释的状态

        List<String> lines = Files.readAllLines(file);
        for (String line : lines) {
            line = line.trim();

            if (line.isEmpty()) {
                stats.blankLines++;
            } else if (blockComment) {
                stats.commentLines++;
                if (line.endsWith("*/")) {
                    blockComment = false;
                }
            } else if (line.startsWith("//")) {
                stats.commentLines++;
            } else if (line.startsWith("/*")) {
                stats.commentLines++;
                if (!line.endsWith("*/")) {
                    blockComment = true;
                }
            } else {
                stats.codeLines++;
            }
        }

        return stats;
    }
}
