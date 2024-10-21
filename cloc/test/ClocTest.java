import org.junit.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.io.IOException;

import static org.junit.Assert.*;

public class ClocTest {

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
