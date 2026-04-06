using System.Text.RegularExpressions;

namespace ReweMappingService.Services;

public static class CloudinaryVersionExtractor
{
    private static readonly Regex VersionPattern = new(@"/v(\d+)/", RegexOptions.Compiled);

    public static string Extract(string url)
    {
        var match = VersionPattern.Match(url);
        return match.Success ? match.Groups[1].Value : string.Empty;
    }
}
