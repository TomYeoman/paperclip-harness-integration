namespace ReweMappingService.Models;

public record StoreDocument(
    string StoreId,
    string TcsUrl,
    string PrivacyUrl,
    string PdfUrl
);
