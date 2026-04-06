using ReweMappingService.Models;
using ReweMappingService.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMemoryCache();
builder.Services.AddSingleton<IStoreDocumentRepository, InMemoryStoreDocumentRepository>();
builder.Services.AddSingleton<IObservabilityService, LogObservabilityService>();

var app = builder.Build();

app.MapGet("/store-docs/{storeId}", (
    string storeId,
    IStoreDocumentRepository repository,
    IObservabilityService observability) =>
{
    var doc = repository.FindByStoreId(storeId);

    if (doc is null)
    {
        observability.EmitLinksMissing(storeId);
        return Results.NotFound(new StoreNotFoundResponse("store_not_found"));
    }

    var versionId = CloudinaryVersionExtractor.Extract(doc.TcsUrl);
    observability.EmitMappingResolved(storeId, doc.TcsUrl, versionId);

    return Results.Ok(new StoreDocsResponse(doc.PdfUrl));
});

app.Run();

public partial class Program { }
