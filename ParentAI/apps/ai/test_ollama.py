from ollama import chat

response = chat(
    model="qwen3:8b",
    messages=[
        {
            "role": "user",
            "content": "Say only: Hello from Python"
        }
    ]
)

print(response["message"]["content"])