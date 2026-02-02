// escrito pelo ChatGPT (na maior parte, e alterado) especificamente para rodar jurosAS.as
// uso (no Linux): ./runAS jurosAS.as
/* compilado com: 
g++ runAS.cpp \
sdk/angelscript/source/*.cpp \
sdk/add_on/scriptarray/scriptarray.cpp \
sdk/add_on/scriptstdstring/scriptstdstring.cpp \
sdk/add_on/scriptmath/scriptmath.cpp \
-Isdk/angelscript/include \
-Isdk/add_on/scriptarray \
-Isdk/add_on/scriptstdstring \
-Isdk/add_on/scriptmath \
-o runAS
*/

#include <assert.h>
#include <fstream>
#include <sstream>
#include <stdio.h>
#include <string>

#include <angelscript.h>

// Add-ons
#include <scriptarray.h>
#include <scriptstdstring.h>
#include <scriptmath.h>

void print(const std::string &msg)
{
    printf("%s", msg.c_str());
}

void printDouble(double v)
{
    printf("%.5f", v);
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        printf("Uso: %s arquivo.as\n", argv[0]);
        return 1;
    }

    // Lê o script inteiro
    std::ifstream file(argv[1]);
    if (!file) {
        printf("Erro ao abrir o arquivo: %s\n", argv[1]);
        return 1;
    }

    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string script = buffer.str();

    // Cria engine
    asIScriptEngine *engine = asCreateScriptEngine();
    assert(engine);

    // Registra add-ons
    RegisterStdString(engine);
    RegisterScriptArray(engine, true);
    RegisterScriptMath(engine);

    // Registra funções globais
    engine->RegisterGlobalFunction(
        "void print(const string &in)",
        asFUNCTION(print),
        asCALL_CDECL
    );

    engine->RegisterGlobalFunction(
        "void printDouble(double)",
        asFUNCTION(printDouble),
        asCALL_CDECL
    );

    // Cria módulo
    asIScriptModule *mod =
        engine->GetModule("main", asGM_ALWAYS_CREATE);

    mod->AddScriptSection(argv[1], script.c_str());

    int r = mod->Build();
    if (r < 0) {
        printf("Erro ao compilar o script.\n");
        engine->ShutDownAndRelease();
        return 1;
    }

    // Procura main()
    asIScriptFunction *func =
        mod->GetFunctionByDecl("void main()");
    if (!func) {
        printf("Função 'void main()' não encontrada.\n");
        engine->ShutDownAndRelease();
        return 1;
    }

    // Executa
    asIScriptContext *ctx = engine->CreateContext();
    ctx->Prepare(func);
    ctx->Execute();
    ctx->Release();

    engine->ShutDownAndRelease();
    return 0;
}
