using Humanizer;
using System.Globalization;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", (HttpContext context) =>
{
    string queryParam = context.Request.Query["n"].ToString();
    
    // Validar que la entrada sea un número válido
    if (long.TryParse(queryParam, out long numero))
    {
        // Convertir el número a palabras usando la localización en español
        return numero.ToWords(new CultureInfo("es-ES"));
    }
    
    return "Por favor, proporcione un número entero válido en la URL (ej: ?n=10).";
});

app.Run();