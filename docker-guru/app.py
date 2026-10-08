import os

import ollama
import streamlit as st

HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
MODEL = os.getenv("MODEL", "llama3.2:1b")
SYSTEM = os.getenv(
    "SYSTEM_PROMPT",
    "Você é um assistente prestativo. Responda sempre em português, de forma curta.",
)

client = ollama.Client(host=HOST)

st.set_page_config(page_title="Chat local", page_icon="💬")
st.title("💬 Chat com IA local")
st.caption(f"Servidor: {HOST} · Modelo: {MODEL}")

if "msgs" not in st.session_state:
    st.session_state.msgs = []

for m in st.session_state.msgs:
    st.chat_message(m["role"]).write(m["content"])

if prompt := st.chat_input("Pergunte algo"):
    st.session_state.msgs.append({"role": "user", "content": prompt})
    st.chat_message("user").write(prompt)

    def resposta():
        msgs = [{"role": "system", "content": SYSTEM}] + st.session_state.msgs
        for chunk in client.chat(model=MODEL, messages=msgs, stream=True):
            yield chunk["message"]["content"]

    try:
        with st.chat_message("assistant"):
            texto = st.write_stream(resposta())
        st.session_state.msgs.append({"role": "assistant", "content": texto})
    except Exception as e:
        st.error(
            f"Não consegui falar com o servidor de IA em {HOST}.\n\n"
            f"Detalhe técnico: {e}"
        )
