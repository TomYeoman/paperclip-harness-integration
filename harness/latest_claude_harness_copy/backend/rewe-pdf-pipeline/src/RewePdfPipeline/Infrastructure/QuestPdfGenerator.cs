using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using RewePdfPipeline.Domain;
using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Infrastructure;

public sealed class QuestPdfGenerator : IPdfGenerator
{
    static QuestPdfGenerator()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    public byte[] GenerateTcsPdf(StoreMetadata store)
    {
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(40);

                page.Header().Column(header =>
                {
                    header.Item().Text("Terms and Conditions").FontSize(20).Bold();
                    header.Item().PaddingTop(8).Text($"Store: {store.StoreName}").FontSize(14);
                    header.Item().PaddingTop(4).Text($"Address: {store.StoreAddress}").FontSize(12);
                });

                page.Content().PaddingTop(20).Column(body =>
                {
                    body.Item().Text(
                        "These Terms and Conditions govern your use of the ordering service provided " +
                        "at the store identified above. By placing an order, you agree to these terms."
                    ).FontSize(10);

                    body.Item().PaddingTop(12).Text(
                        $"Store Name: {store.StoreName}"
                    ).FontSize(10).Bold();

                    body.Item().PaddingTop(4).Text(
                        $"Store Address: {store.StoreAddress}"
                    ).FontSize(10).Bold();
                });

                page.Footer().AlignRight().Text(text =>
                {
                    text.Span("Page ");
                    text.CurrentPageNumber();
                    text.Span(" of ");
                    text.TotalPages();
                });
            });
        }).GeneratePdf();
    }
}
