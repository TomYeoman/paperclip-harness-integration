using RewePdfPipeline.Domain;
using RewePdfPipeline.Infrastructure;
using Xunit;

namespace RewePdfPipeline.Tests.Infrastructure;

public sealed class QuestPdfGeneratorTests
{
    [Fact]
    public void GenerateTcsPdf_ReturnsPdfBytes_WithNonZeroLength()
    {
        var generator = new QuestPdfGenerator();
        var store = new StoreMetadata("REWE_TEST_999", "REWE Test Store 999", "Teststraße 1, 10115 Berlin");

        var bytes = generator.GenerateTcsPdf(store);

        Assert.NotNull(bytes);
        Assert.True(bytes.Length > 0);
    }

    [Fact]
    public void GenerateTcsPdf_ReturnsPdfBytes_StartingWithPdfMagicBytes()
    {
        var generator = new QuestPdfGenerator();
        var store = new StoreMetadata("REWE_TEST_999", "REWE Test Store 999", "Teststraße 1, 10115 Berlin");

        var bytes = generator.GenerateTcsPdf(store);

        // PDF files start with %PDF
        var header = System.Text.Encoding.ASCII.GetString(bytes, 0, 4);
        Assert.Equal("%PDF", header);
    }
}
