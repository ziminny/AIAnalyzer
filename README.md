# AIAnalyzer

AIAnalyzer é um Swift Package focado em fornecer uma interface simples e
extensível para executar análises de IA sobre mídia utilizando CoreML.

O objetivo principal do package é abstrair a complexidade dos modelos de
IA e oferecer uma API limpa baseada em pipeline.

------------------------------------------------------------------------

## ✨ Features

-   Arquitetura baseada em Strategy Pattern
-   Type Erasure para suportar múltiplos analyzers
-   Pipeline extensível para diferentes tipos de mídia
-   Integração com CoreML
-   API simples e desacoplada da implementação interna

------------------------------------------------------------------------

## 🧠 Conceito

`AIAnalyzer` funciona como um orquestrador responsável por:

-   Registrar diferentes estratégias de análise (`AnyAnalysis`)
-   Selecionar automaticamente o analyzer correto baseado no tipo de
    mídia
-   Executar o processamento e retornar o resultado

O consumidor do package não precisa conhecer os detalhes internos dos
modelos.

------------------------------------------------------------------------

## 📦 Instalação (Swift Package Manager)

No Xcode:

File → Add Package Dependencies

Adicionar:

https://github.com/ziminny/AIAnalyzer

Ou via Package.swift:

``` swift
.package(url: "https://github.com/ziminny/AIAnalyzer", from: "1.0.0")
```

------------------------------------------------------------------------

## 🚀 Uso básico

``` swift
let analyzer = AIAnalyzer()

analyzer.imageAnalyze(
    image: image,
    metadata: [:]
) { result in
    print(result)
}
```

------------------------------------------------------------------------

## 🏗 Arquitetura

O package utiliza:

-   Strategy Pattern
-   Type Erasure (`AnyAnalysis`)
-   Pipeline centralizado

Separando:

-   API pública
-   Implementação dos modelos CoreML

Isso permite adicionar novos analyzers sem alterar a interface pública.

------------------------------------------------------------------------

## 🔌 Extensibilidade

Novos analyzers podem ser adicionados registrando-os na inicialização:

``` swift
public init() {
    self.analisys = [
        AnyAnalysis(PhotoAIAnalyzer())
    ]
}
```

------------------------------------------------------------------------

## 🧵 Thread Safety

`AIAnalyzer` é imutável após inicialização.

Se algum analyzer interno não for thread-safe, a sincronização deve ser
tratada na implementação concreta.

------------------------------------------------------------------------

## 📁 Requisitos

-   iOS 16+
-   Swift 5.9+
-   CoreML

------------------------------------------------------------------------

## ⚠️ Observações

-   O package assume que os modelos CoreML necessários já estão
    disponíveis nos resources do Swift Package.
-   A ordem dos analyzers pode influenciar a prioridade de seleção.

------------------------------------------------------------------------

## 🤝 Contribuição

Pull Requests são bem-vindos.

------------------------------------------------------------------------

## 📄 Licença

MIT
