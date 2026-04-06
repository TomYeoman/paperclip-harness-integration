using CloudinaryDotNet;
using RewePdfPipeline.Infrastructure;
using RewePdfPipeline.Pipeline;

var cloudName = Environment.GetEnvironmentVariable("CLOUDINARY_CLOUD_NAME")
    ?? throw new InvalidOperationException("CLOUDINARY_CLOUD_NAME is required.");
var apiKey = Environment.GetEnvironmentVariable("CLOUDINARY_API_KEY")
    ?? throw new InvalidOperationException("CLOUDINARY_API_KEY is required.");
var apiSecret = Environment.GetEnvironmentVariable("CLOUDINARY_API_SECRET")
    ?? throw new InvalidOperationException("CLOUDINARY_API_SECRET is required.");

var restaurantServiceUrl = Environment.GetEnvironmentVariable("RESTAURANT_SERVICE_URL")
    ?? throw new InvalidOperationException("RESTAURANT_SERVICE_URL is required.");

var mappingServiceUrl = Environment.GetEnvironmentVariable("MAPPING_SERVICE_URL")
    ?? throw new InvalidOperationException("MAPPING_SERVICE_URL is required.");

var storeId = args.Length > 0 ? args[0] : null;
if (string.IsNullOrWhiteSpace(storeId))
{
    Console.Error.WriteLine("Usage: RewePdfPipeline <store_id>");
    return 1;
}

var cloudinary = new Cloudinary(new Account(cloudName, apiKey, apiSecret))
{
    Api = { Secure = true },
};

var httpTimeout = TimeSpan.FromSeconds(30);
using var restaurantHttpClient = new HttpClient { BaseAddress = new Uri(restaurantServiceUrl), Timeout = httpTimeout };
using var mappingHttpClient = new HttpClient { BaseAddress = new Uri(mappingServiceUrl), Timeout = httpTimeout };

var pipeline = new PdfGenerationPipeline(
    restaurantClient: new RestaurantServiceClient(restaurantHttpClient),
    pdfGenerator: new QuestPdfGenerator(),
    cloudinaryClient: new CloudinaryPdfClient(cloudinary),
    mappingRegistrar: new MappingServiceRegistrar(mappingHttpClient),
    observabilityLogger: new JsonObservabilityLogger()
);

try
{
    var result = await pipeline.RunAsync(storeId);
    Console.WriteLine($"Pipeline complete: store={result.StoreId} pdf_url={result.PdfUrl} size={result.PdfSizeBytes}B");
    return 0;
}
catch (InvalidOperationException ex)
{
    Console.Error.WriteLine($"Pipeline aborted: {ex.Message}");
    return 2;
}
catch (HttpRequestException ex)
{
    Console.Error.WriteLine($"Pipeline failed (service unavailable — retry): {ex.Message}");
    return 3;
}
