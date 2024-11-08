# actions/actions.py

from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker # type: ignore
from rasa_sdk.executor import CollectingDispatcher # type: ignore

class ActionSayHello(Action):
    def name(self) -> Text:
        return "action_say_hello"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        dispatcher.utter_message(text="Personalizada: Oi! Estou aqui para te ajudar. Como posso te ajudar hoje?")
        return []
