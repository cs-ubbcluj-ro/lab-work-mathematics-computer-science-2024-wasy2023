import re

class FiniteAutomaton:
    def __init__(self):
        self.states = set()
        self.alphabet = set()
        self.transitions = {}
        self.initial_state = None
        self.final_states = set()

    def add_transition(self, from_state, to_state, symbol):
        if from_state not in self.transitions:
            self.transitions[from_state] = {}
        self.transitions[from_state][symbol] = to_state

    def display(self):
        print("Set of States:", self.states)
        print("Alphabet:", self.alphabet)
        print("Transitions:")
        for state, symbols in self.transitions.items():
            for symbol, next_state in symbols.items():
                print(f"  {state} --{symbol}--> {next_state}")
        print("Initial State:", self.initial_state)
        print("Final States:", self.final_states)

    def is_valid_token(self, string):
        current_state = self.initial_state
        for char in string:
            if char in self.alphabet and current_state in self.transitions:
                if char in self.transitions[current_state]:
                    current_state = self.transitions[current_state][char]
                else:
                    return False
            else:
                return False
        return current_state in self.final_states

def parse_fa(filename):
    fa = FiniteAutomaton()

    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()

            if line.startswith("states:"):
                states = re.findall(r'\b\w+\b', line.split(":")[1])
                fa.states.update(states)

            elif line.startswith("alphabet:"):
                alphabet = re.findall(r'\b\w+\b', line.split(":")[1])
                fa.alphabet.update(alphabet)

            elif line.startswith("transitions:"):
                continue

            elif "->" in line and ":" in line:
                parts = re.split(r'->|:', line)
                from_state = parts[0].strip()
                to_state = parts[1].strip()
                symbol = parts[2].strip()
                fa.add_transition(from_state, to_state, symbol)

            elif line.startswith("initial_state:"):
                fa.initial_state = line.split(":")[1].strip()

            elif line.startswith("final_states:"):
                final_states = re.findall(r'\b\w+\b', line.split(":")[1])
                fa.final_states.update(final_states)

    return fa

if __name__ == "__main__":
    fa = parse_fa("FA.in")
    fa.display()

    test_string = input("Enter a string to check if it is a valid token: ")
    if fa.is_valid_token(test_string):
        print(f"The string '{test_string}' is a valid lexical token.")
    else:
        print(f"The string '{test_string}' is NOT a valid lexical token.")
