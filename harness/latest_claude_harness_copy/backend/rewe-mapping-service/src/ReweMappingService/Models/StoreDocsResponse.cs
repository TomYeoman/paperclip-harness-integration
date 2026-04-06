using System.Text.Json.Serialization;

namespace ReweMappingService.Models;

public record StoreDocsResponse(
    [property: JsonPropertyName("pdf_url")] string PdfUrl
);

public record StoreNotFoundResponse(
    [property: JsonPropertyName("error")] string Error
);
