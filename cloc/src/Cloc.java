import java.io.*;
import java.nio.file.*;
import java.util.*;

public class Cloc {

    private static class FileStats {
        int codeLines = 0;
        int commentLines = 0;
        int blankLines = 0;

        void add(FileStats other) {
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
        if (args.length != 1 || args[0] == "-h" || args[0] == "--help") {
            System.out.println("Usage: java CodeCounter <file or directory path>");
            return;
        }

        Path path = Paths.get(args[0]);
        if (!Files.exists(path)) {
            System.out.println("File or directory does not exist.");
            return;
        }

        FileStats totalStats = new FileStats();

        try {
            if (Files.isDirectory(path)) {
                // 递归处理目录
                Files.walk(path).filter(Files::isRegularFile).forEach(file -> {
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

    private static FileStats processFile(Path file) throws IOException {
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
