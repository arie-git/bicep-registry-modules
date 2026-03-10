import os
import json
from dotenv import load_dotenv, find_dotenv
from openai import AzureOpenAI
from azure.identity import get_bearer_token_provider

load_dotenv(find_dotenv())


endpoint = os.getenv("ENDPOINT")
deployment = os.getenv("DEPLOYMENT")
api_version = os.getenv("API_VERSION")


def get_initial_response(search_text: str, control_id: str, credential):
    """
    Generate the initial response based on search_text and control_id.
    Returns the assistant's reply and the initial message list.
    Uses the provided OBO credential for Azure OpenAI access.
    """
    token_provider = get_bearer_token_provider(
        credential, "https://cognitiveservices.azure.com/.default"
    )

    client = AzureOpenAI(
        azure_endpoint=endpoint,
        azure_ad_token_provider=token_provider,
        api_version=api_version,
    )
    messages = [
        {
            "role": "system",
            "content": (
                "You are a technical assistant helping with Azure policy compliance. "
                "Explain remediation clearly, include CLI/Portal steps if relevant."
            ),
        },
        {"role": "system", "content": f"Knowledge base context:\n{search_text}"},
        {
            "role": "user",
            "content": f"I have a policy violation with ID {control_id}. "
            "What does this policy mean and how do I remediate it?",
        },
    ]

    completion = client.chat.completions.create(
        model=deployment, messages=messages, temperature=0.7, max_tokens=2000
    )

    assistant_reply = completion.choices[0].message.content
    messages.append({"role": "assistant", "content": assistant_reply})

    return {"answer": assistant_reply, "messages": messages}


def get_followup_response(messages: list, user_input: str, credential):
    """
    Continue the conversation using the provided message history.
    Uses the provided OBO credential for Azure OpenAI access.
    """
    token_provider = get_bearer_token_provider(
        credential, "https://cognitiveservices.azure.com/.default"
    )

    client = AzureOpenAI(
        azure_endpoint=endpoint,
        azure_ad_token_provider=token_provider,
        api_version=api_version,
    )

    messages.append({"role": "user", "content": user_input})

    completion = client.chat.completions.create(
        model=deployment, messages=messages, temperature=0.2
    )

    assistant_reply = completion.choices[0].message.content
    messages.append({"role": "assistant", "content": assistant_reply})

    return {"answer": assistant_reply, "messages": messages}
