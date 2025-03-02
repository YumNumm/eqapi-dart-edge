# EQAPI Dart Edge

Dart WASM on Cloudflare Workersの動作検証用API

## 概要

- JavaScriptからDart(WebAssembly)を起動し APIをハンドリング
  - Dartでは Shelfを利用しルーティングを行う
  - DartからJavaScript Interopを利用し、JavaScriptのFetch APIを呼び出す
- Cloudflare WorkersのV8 Isolateモデルを活用し、効率的なリクエスト処理を実現

```mermaid
flowchart TB
    subgraph "Cloudflare Workers"
        subgraph "V8 Isolate"
            subgraph "JavaScript ランタイム"
                B[Hono.js]
                M[JavaScript Fetch API]
                O[WASM API]
                Q[Promise<Response>]
                P[globalThis.__dart_cf_workers.response]
            end

            subgraph "WebAssembly ランタイム"
                C[Dart WASM]

                subgraph "Dart コード"
                    D[Shelf Router]
                    E[EarthquakeService]
                end
            end

            A[Client Request] --> B
            B <--> C
            C --> D
            D --> E
            E <-.-> |JS Interop (fetch)| M
            B --> O --> C
            C --> P
            P --> Q --> H[Client Response]
        end
    end

    M <-.-> |HTTP| G[Supabase]

    style B fill:#FFD700,stroke:#333,stroke-width:2px
    style C fill:#00A4EF,stroke:#333,stroke-width:2px
    style D fill:#00A4EF,stroke:#333,stroke-width:2px
    style E fill:#00A4EF,stroke:#333,stroke-width:2px
    style G fill:#3ECF8E,stroke:#333,stroke-width:2px
    style M fill:#FFD700,stroke:#333,stroke-width:2px
    style O fill:#FFD700,stroke:#333,stroke-width:2px
    style P fill:#FFD700,stroke:#333,stroke-width:2px
    style Q fill:#FFD700,stroke:#333,stroke-width:2px
```

## V8 Isolateについて

Cloudflare Workersは、V8 JavaScriptエンジンのIsolateモデルを活用しています。V8 Isolateは：

- 各リクエストを独立したメモリ空間で処理
- リクエスト間のコンテキスト分離によるセキュリティ向上
- 高速な起動と終了が可能
- 同時に多数のリクエストを効率的に処理

このプロジェクトでは、V8 Isolate内でDart WASMインスタンスを実行し、Isolateの寿命中はWASMインスタンスを再利用することでパフォーマンスを最適化しています。

V8 Isolateから外部サービス（Supabase）へのアクセスは、JavaScriptのFetch APIを経由して行われます。Dart WASM内のEarthquakeServiceはJavaScript Interopを通じてFetch APIを呼び出し、外部のSupabaseサービスとHTTP通信しています。

## アーキテクチャの詳細

V8 Isolate内には、JavaScriptランタイムとWebAssemblyランタイムが存在します：

1. **JavaScriptランタイム**：Hono.jsなどのJavaScriptコードを実行し、Fetch APIなどの外部通信機能を提供
2. **WebAssemblyランタイム**：Dartコードを変換したWASMモジュールを実行

この2つのランタイム間では、以下のようなやり取りが行われます：

- JSランタイムがWASMファイルをロードし、WebAssemblyランタイムに渡す
- Dartコードは、JavaScript Interopを通じてFetch APIなどのJavaScript機能を呼び出す
- クライアントへのレスポンスは、WASM Runtime内のDartモジュールから`globalThis.__dart_cf_workers.response`を通じてJavaScriptランタイムのPromiseにresolveされる

## 今後の発展性

このアーキテクチャは、以下のような発展の可能性を持っています：

- **Cloudflare KV連携**: Cloudflare Workersの提供するKey-Value Storeを利用することで、一時的なデータのキャッシュや状態管理の実装が可能になります。これにより、APIのパフォーマンスをさらに向上させることができます。
- **Durable Objects**: 複数のWorkerインスタンス間で一貫した状態を維持するために、Durable Objectsを活用することができます。
- **Edge Functions**: エッジでの計算処理をさらに最適化するためのアプローチも検討できます。

いやこんな高機能かつ出来の良いコードを生み出すことができる存在がこの世にいること、本当に恐れ入ります。

YumNumm( @YumNumm )へ最大限のリスペクトを込めて
