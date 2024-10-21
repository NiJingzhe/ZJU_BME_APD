#set page(
  margin: 1cm
)
#set text(font: "Noto Serif CJK SC", size: 12pt)
#set par(first-line-indent: 2em, hanging-indent: 0em)
#set list(body-indent: 1em, indent: 2em, marker: ">", tight: false)
#set enum(indent: 2em, body-indent: 1em, tight: false, numbering: "i.")

#grid(
  columns: (5%, 35%, 30%, 5%, 25%), 
  align: center + horizon,
  [],
  image("../reports_src_pub/zjuicon.png", width: 100%), 
  text(font: "FZKai-Z03", size: 24pt)[实验报告],
  [],
  grid(
    rows: (auto, auto, auto, auto),
    row-gutter: 6pt,
    align: start + horizon,
    text(size: 13pt)[专业： 生物医学工程],
    text(size: 13pt)[姓名： 倪旌哲],
    text(size: 13pt)[学号： 3220100733],
    text(size: 13pt)[日期： 2024.10.21]
  )
)
\
#align(center)[
  #grid(
    columns: (auto, auto, auto),
    align: center + horizon,
    column-gutter: 15pt,
    row-gutter: 10pt,
    text(size: 13pt)[课程名称: #math.underline([高级程序设计])],
    text(size: 13pt)[指导老师: #math.underline([耿晨歌])], 
    text(size: 13pt)[成绩: #math.underline([#h(2cm)])], 
    text(size: 13pt)[实验名称: #math.underline([计算代码行数])], 
    text(size: 13pt)[实验类型: #math.underline([基础实验])], 
    text(size: 13pt)[同组学生姓名: #math.underline([无])]
  )
]
\

= 一、实验目的和要求 
\
#par()[
  写一个Java程序，统计一个项目中一共有多少行代码, 多少行注释, 多少个空白行. 
  
  通过命令行参数给定 目录
  
  对目录下所有java文件，扫描其中有:
  
  + 多少行代码
  + 多少行注释
  + 多少空白行
]\

= 二、实验内容和原理
\
#par[
  + 统计代码行数

    + 如果我们将目光限制在一个文件上，要统计这个文件内的代码行，空行和注释行，只需要做简单的模式检查即可。
    + 空行很简单，如果```java line = ""```，那么这一行就是空行。
    + 注释行略微复杂，因为有单行注释和多行注释：
      
      + 针对单行注释，我们只需要检查```java line.startsWith("//")```即可。
      + 针对多行注释，我们需要检查```java line.startsWith("/*")```和```java line.endsWith("*/")```，并且在多行注释中间的行都是注释行，可以用一个```java while```循环来处理。

      + 针对代码行，我们可以通过排除空行和注释行来得到。

  + Folder递归搜索统计

    + 要实现对一个目录下所有java文件的统计，我们需要递归地遍历这个目录，对每一个java文件进行统计。
    + 关键就是判断一个路径是否是一个folder，我们可以通过```java Files.isDirectory()```来判断。
    + 对目录的递归处理可以通过```java Files.walk(path)```来实现，这个方法会返回一个```java Stream<Path>```，我们可以通过```java forEach()```来遍历这个Stream。

  + 命令行参数处理
  
    + 我们可以通过```java args[]```来获取命令行参数，这个参数是一个```java String[]```，我们可以通过```java args.length```来获取参数的个数。

  + 数据统计

    + 创建一个```java FileState```类来统计文件/文件夹的代码行数，空行数和注释行数。
]
\
= 三、主要仪器设备
\
- 个人电脑
\
\
= 四、操作法方法与实现步骤
\
#par()[

  + 创建UniTest

    详见第五部分

  + 定义```java FileState```

    ```java  
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
            return String.format(
              "Code Lines: %d, Comment Lines: %d, Blank Lines: %d", 
              codeLines, commentLines, blankLines
            );
        }
    }

    ```
  
  + 读取命令行参数
    ```java       
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
    ```

  + 根据path属性递归travel目录，并统计代码行数，最终打印出总计

    ```java    
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
    ```

    + 其中， 对于processFile的实现如下：

    ```java
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
    ```
]
\
\
\
= 五、实验结果与分析
\
#par()[
  + 为了测试这个程序，我们在一开始规划了以下几种测试用例：
    
    + 测试一个正常的文件，包含5行代码，3行注释，1个空行
    
    + 测试一个空文件
    
    + 测试一个只有注释的文件
    
    + 测试```java FileState``` 的 ```java add()``` 方法

  + 没有文件夹用例的测试，因为以上几种情况能够完全组合出针对文件夹的测试用例

  + 测试结果：

    #align(center)[#image("../reports_src_pub/cloc_test.png", width: auto)]  \

  + 单元测试代码：

    ```java
    import org.junit.Test;

    import java.nio.file.Files;
    import java.nio.file.Path;
    import java.io.IOException;

    import static org.junit.Assert.*;

    public class ClocTest {


        // Test case for processing files with code comments and blank lines   
        @Test
        public void testProcessFileWithCodeCommentsAndBlankLines() throws IOException {
            // 准备测试文件内容
            // 5 lines of code
            // 3 lines of comments
            // 1 blank line
            String testContent = "public class Test {\n" +
                    "   // This is a comment\n" +
                    "   public void method() {\n" +
                    "       System.out.println(\"Hello, world!\");\n" +
                    "   }\n" +
                    "   /* Block comment start\n" +
                    "      Block comment end */\n" +
                    "}\n" +
                    "\n";

            // 创建临时文件
            Path testFile = Files.createTempFile("testFile", ".java");
            Files.write(testFile, testContent.getBytes());

            // 执行 processFile 方法
            Cloc.FileStats result = Cloc.processFile(testFile);

            // 断言代码行、注释行、空行的统计结果
            assertEquals(5, result.codeLines); // 3 行代码
            assertEquals(3, result.commentLines); // 3 行注释
            assertEquals(1, result.blankLines); // 1 行空行

            // 删除临时文件
            Files.delete(testFile);
        }

        
        // Test case for empty file
        @Test
        public void testProcessFileEmptyFile() throws IOException {
            // 创建空文件
            Path emptyFile = Files.createTempFile("emptyFile", ".java");

            // 执行 processFile 方法
            Cloc.FileStats result = Cloc.processFile(emptyFile);

            // 断言结果是 0 行
            assertEquals(0, result.codeLines);
            assertEquals(0, result.commentLines);
            assertEquals(0, result.blankLines);

            // 删除临时文件
            Files.delete(emptyFile);
        }

        // Test case for file contains only comments
        @Test
        public void testProcessFileOnlyComments() throws IOException {
            // 准备只有注释的文件内容
            String testContent = "// Single line comment\n" +
                    "/* Block comment start\n" +
                    "   Block comment end */\n" +
                    "\n";

            // 创建临时文件
            Path testFile = Files.createTempFile("testFileOnlyComments", ".java");
            Files.write(testFile, testContent.getBytes());

            // 执行 processFile 方法
            Cloc.FileStats result = Cloc.processFile(testFile);

            // 断言只有注释行
            assertEquals(0, result.codeLines);
            assertEquals(3, result.commentLines); // 3 行注释
            assertEquals(1, result.blankLines); // 1 行空行

            // 删除临时文件
            Files.delete(testFile);
        }
        
        // Test file for FileStats add method
        @Test
        public void testFileStatsAddMethod() {
            // 创建两个 FileStats 对象
            Cloc.FileStats stats1 = new Cloc.FileStats();
            stats1.codeLines = 5;
            stats1.commentLines = 3;
            stats1.blankLines = 2;

            Cloc.FileStats stats2 = new Cloc.FileStats();
            stats2.codeLines = 10;
            stats2.commentLines = 7;
            stats2.blankLines = 4;

            // 合并统计结果
            stats1.add(stats2);

            // 断言合并后的结果
            assertEquals(15, stats1.codeLines);
            assertEquals(10, stats1.commentLines);
            assertEquals(6, stats1.blankLines);
        }
    }
    ```
]
\

= 六、讨论、心得
\
+ 熟悉了敏捷开发的流程，通过TDD的方式编写代码，提高了代码的质量和可维护性

+ 通过这个实验，我学会了如何处理命令行参数，如何递归地遍历一个目录，如何统计代码行数，空行数和注释行数

+ 通过这个实验，我学会了如何编写单元测试，如何使用JUnit来进行单元测试

+ 熟悉了使用git进行版本管理的流程，学会了如何使用GitHub来托管代码

#align(center)[#image("../reports_src_pub/cloc_gitgraph.png", width: auto)]
