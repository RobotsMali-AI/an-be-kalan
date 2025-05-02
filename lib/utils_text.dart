Map<String, dynamic> languageText = {
  'br': 'Welcome',
};
String getText(String text) => languageText[text] ?? '';
