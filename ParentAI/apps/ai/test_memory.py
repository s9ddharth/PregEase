from app.memory.database_memory_manager import database_memory_manager


session_id = "test-session-001"

print("Saving message...")

database_memory_manager.add_message(
    session_id=session_id,
    role="user",
    content="Hello, this is a database memory test."
)

print("Reading messages...")

messages = database_memory_manager.get_messages(session_id)

print(messages)