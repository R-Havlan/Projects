// Reuben Havlan, Darryn Dunn, Matthew Kunkel

#include <bits/stdc++.h>
#include <iostream>
#include <set>

using namespace std;

// Valid characters for a variable name includes underscores
bool isLetter(const char &character) {
  return isalpha(character) || character == '_';
}

// checking a string for a valid variable name
bool validName(string name) {

  // special case for first character because it can't start with a digit
  if (!isLetter(name.at(0))) {
    return false;
  }

  for (char x : name) {
    if (!isLetter(x) && !isdigit(x)) {
      return false;
    }
  }

  return true;
}

// assigns each token a type and places them in the corresponding types[]
// e: equal, o: operator, n: number, v:variable
// returns true if all tokens are valid, else returns false
bool getTypes(string *tokens, char *types) {
  set<string> operators = {"+", "-", "*", "/"};
  for (int x = 0; x < 5; x++) {
    if (tokens[x] == "=") {
      types[x] = 'e';
    } else if (operators.count(tokens[x])) {
      types[x] = 'o';
    } else if (all_of(tokens[x].begin(), tokens[x].end(), ::isdigit)) {
      types[x] = 'n';
    } else if (validName(tokens[x])) {
      types[x] = 'v';
    } else {
      return 0;
    }
  }
  return 1;
}

// Looks at the types and determines if the syntax is correct
// types[1] and types[3] need to be an operator-eqals pair
// types[0,2,4] need to be either number or variable
bool validSyntax(const char *types) { 
  if(types[1] == 'o') {
    if(types[3] != 'e') {
      cout << "Invalid syntax: Expected an equal sign\n";
      return false;
    }
  } else if (types[1] == 'e') {
    if(types[3] != 'o') {
      cout << "Invalid syntax: Expected an operator sign\n";
      return false;
    }
  } else {
    cout << "Invalid syntax: Expected an operator and equal sign\n";
    return false;
  }

  if(types[0] != 'n' && types[0] != 'v') {
    cout << "Invalid syntax: Expected number or variable\n";
    return false;
  }
  if(types[2] != 'n' && types[2] != 'v') {
    cout << "Invalid syntax: Expected number or variable\n";
    return false;
  }
  if(types[4] != 'n' && types[4] != 'v') {
    cout << "Invalid syntax: Expected number or variable\n";
    return false;
  }
  cout << "Valid syntax\n";
  return true;
}

// Function to see if a value is in an array
template <class T> 
int arrayCount(T *array, T key) {
  int count = 0;
  for (int x = 0; x < 5; x++) {
    if (array[x] == key) count++;
  }
  return count;
}

void solveForVariable(string *tokens, char *types) {
  if(types[0] == 'v') {
    if(types[1] == 'e') {
      // variable = number op number
      switch(tokens[3][0]) {
        case '+': cout << tokens[0] << " = " << stoi(tokens[2]) + stoi(tokens[4]); break;
        case '-': cout << tokens[0] << " = " << stoi(tokens[2]) - stoi(tokens[4]); break;
        case '*': cout << tokens[0] << " = " << stoi(tokens[2]) * stoi(tokens[4]); break;
        case '/': cout << tokens[0] << " = " << stoi(tokens[2]) / stoi(tokens[4]); break;
      }
    } else {
      // variable op number = number
      switch(tokens[1][0]) {
        case '+': cout << tokens[0] << " = " << stoi(tokens[4]) - stoi(tokens[2]); break;
        case '-': cout << tokens[0] << " = " << stoi(tokens[4]) + stoi(tokens[2]); break;
        case '*': cout << tokens[0] << " = " << stoi(tokens[4]) / stoi(tokens[2]); break;
        case '/': cout << tokens[0] << " = " << stoi(tokens[4]) * stoi(tokens[2]); break;
      }
    }
  } else if(types[2] == 'v') {
    if(types[1] == 'e') {
      // number = variable op number
      switch(tokens[3][0]) {
        case '+': cout << tokens[2] << " = " << stoi(tokens[0]) - stoi(tokens[4]); break;
        case '-': cout << tokens[2] << " = " << stoi(tokens[0]) + stoi(tokens[4]); break;
        case '*': cout << tokens[2] << " = " << stoi(tokens[0]) / stoi(tokens[4]); break;
        case '/': cout << tokens[2] << " = " << stoi(tokens[0]) * stoi(tokens[4]); break;
      }
    } else {
      // number op variable = number
      switch(tokens[1][0]) {
        case '+': cout << tokens[2] << " = " << stoi(tokens[4]) - stoi(tokens[0]); break;
        case '-': cout << tokens[2] << " = " << stoi(tokens[0]) - stoi(tokens[4]); break;
        case '*': cout << tokens[2] << " = " << stoi(tokens[4]) / stoi(tokens[0]); break;
        case '/': cout << tokens[2] << " = " << stoi(tokens[0]) / stoi(tokens[4]); break;
      }
    }
  } else if(types[4] == 'v') {
    if(types[1] == 'e') {
      // number = number op variable
      switch(tokens[3][0]) {
        case '+': cout << tokens[4] << " = " << stoi(tokens[0]) - stoi(tokens[2]); break;
        case '-': cout << tokens[4] << " = " << stoi(tokens[2]) - stoi(tokens[0]); break;
        case '*': cout << tokens[4] << " = " << stoi(tokens[0]) / stoi(tokens[2]); break;
        case '/': cout << tokens[4] << " = " << stoi(tokens[2]) / stoi(tokens[0]); break;
      }
    } else {
      // number op number = variable
      switch(tokens[1][0]) {
        case '+': cout << tokens[4] << " = " << stoi(tokens[0]) + stoi(tokens[2]); break;
        case '-': cout << tokens[4] << " = " << stoi(tokens[0]) - stoi(tokens[2]); break;
        case '*': cout << tokens[4] << " = " << stoi(tokens[0]) * stoi(tokens[2]); break;
        case '/': cout << tokens[4] << " = " << stoi(tokens[0]) / stoi(tokens[2]); break;
      }
    }
  } else {
    cout << "Something went wrong";
  }
}

void solveNumbers(string *tokens, char *types) {
  if(types[1] == 'e') {
    // number = number op number
    switch(tokens[3][0]) {
      case '+': stoi(tokens[0]) == stoi(tokens[2]) + stoi(tokens[4]) ? cout << "True statement\n" : cout << "False statement\n"; break;
      case '-': stoi(tokens[0]) == stoi(tokens[2]) - stoi(tokens[4]) ? cout << "True statement\n" : cout << "False statement\n"; break;
      case '*': stoi(tokens[0]) == stoi(tokens[2]) * stoi(tokens[4]) ? cout << "True statement\n" : cout << "False statement\n"; break;
      case '/': stoi(tokens[0]) == stoi(tokens[2]) / stoi(tokens[4]) ? cout << "True statement\n" : cout << "False statement\n"; break;
    }
  } else if(types[3] == 'e') {
    // number op number = number
    switch(tokens[1][0]) {
      case '+': stoi(tokens[4]) == stoi(tokens[0]) + stoi(tokens[2]) ? cout << "True statement\n" : cout << "False statement\n"; break;
      case '-': stoi(tokens[4]) == stoi(tokens[0]) - stoi(tokens[2]) ? cout << "True statement\n" : cout << "False statement\n"; break;
      case '*': stoi(tokens[4]) == stoi(tokens[0]) * stoi(tokens[2]) ? cout << "True statement\n" : cout << "False statement\n"; break;
      case '/': stoi(tokens[4]) == stoi(tokens[0]) / stoi(tokens[2]) ? cout << "True statement\n" : cout << "False statement\n"; break;
    }
  } else {
    cout << "Something went wrong";
  }
}

void solve(string *tokens, char *types) {
  if(arrayCount(types, 'v') > 1) {
    cout << "Unsolvable\n";
  } else if(arrayCount(types, 'v') == 1) {
    solveForVariable(tokens, types);
  } else {
    solveNumbers(tokens, types);
  }
}

int main() {
  
  string tokens[5];
  char types[5];

  while(true) {
    cout << "Enter an expression: ";
    cin >> tokens[0] >> tokens[1] >> tokens[2] >> tokens[3] >> tokens[4];
    if(getTypes(tokens, types)) {
      if(validSyntax(types)) {
        break;
      } else {
        cout << "Invalid syntax\n";
      }
    } else {
      cout << "Invalid input tokens\n";
    }
  }

  solve(tokens, types);
  
  return 0;
}