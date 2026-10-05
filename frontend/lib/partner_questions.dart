import 'dart:math';

class PartnerQuestion {
  final String category;
  final String text;

  const PartnerQuestion({
    required this.category,
    required this.text,
  });
}

const List<PartnerQuestion> partnerQuestions = [
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If our relationship had a warning label, what would it say?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What\'s one tiny thing I do that always makes you feel loved?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'If you could instantly become amazing at one completely useless skill, what would it be?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'What\'s something I do that you find unexpectedly attractive?',
  ),
  PartnerQuestion(
    category: '🎭 Hypothetical',
    text: 'If we had to live in a movie universe for a year, which one would you choose?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What\'s one memory of us that you hope you never forget?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If I were a household appliance, which one would I be and why?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'If we could replay one date we\'ve had, which one would you pick?',
  ),
  PartnerQuestion(
    category: '🌶️ Playful',
    text: 'What\'s something romantic you\'ve wanted us to try but never suggested?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What is a completely ordinary thing that makes you ridiculously happy?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If our love story were a badly made reality show, what would the title be?',
  ),
  PartnerQuestion(
    category: '👫 Relationship',
    text: 'What do you think we are surprisingly good at as a couple?',
  ),
  PartnerQuestion(
    category: '🎲 Would You Rather',
    text: 'Would you rather have a surprise date every week or one huge surprise trip every year?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What was the first thing about me that made you think, \'I like this person\'?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'If you could delete one annoying everyday chore forever, which one goes?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If we opened a restaurant together, what would we call it?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What\'s something about me you appreciate more now than when we first met?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'If you had to describe my flirting style using three words, what would they be?',
  ),
  PartnerQuestion(
    category: '🎭 Hypothetical',
    text: 'If we switched lives for 24 hours, what would you do first?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What\'s the weirdest food combination you secretly think is delicious?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If our relationship had a customer review, how many stars would you give it and why?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What song feels a little bit like \'us\'?',
  ),
  PartnerQuestion(
    category: '👶 Future',
    text: 'What ridiculous personality trait do you think our future child might inherit from me?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'What\'s an outfit of mine you secretly love?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'If you could teleport us anywhere for dinner tonight, where are we eating?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What\'s one thing I\'ve done for you that you still remember clearly?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If we became famous tomorrow, what would we probably be famous for?',
  ),
  PartnerQuestion(
    category: '🎲 Would You Rather',
    text: 'Would you rather have unlimited date nights or unlimited vacation days?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What\'s one little ritual you\'d love for us to keep forever?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What fictional character do you think has a personality suspiciously similar to mine?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If I were a flavor of ice cream, what flavor would I be?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'What\'s the most attractive thing about me that has nothing to do with looks?',
  ),
  PartnerQuestion(
    category: '🎭 Hypothetical',
    text: 'If money didn\'t matter for one weekend, what would our perfect weekend look like?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'When do you feel most like we\'re a team?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'What is one totally unnecessary thing you\'d buy if someone gave you \$1,000 right now?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What place would you love for us to visit together someday?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If we had to communicate only through movie quotes for a day, who would survive longer?',
  ),
  PartnerQuestion(
    category: '👫 Relationship',
    text: 'What\'s one thing you think we\'ve taught each other?',
  ),
  PartnerQuestion(
    category: '🌶️ Playful',
    text: 'What\'s something I do that can still make you blush?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What\'s a tiny hill you would absolutely die on in an argument?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If we had a couple superhero name, what would it be?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What makes a normal day with me feel special?',
  ),
  PartnerQuestion(
    category: '🎲 Would You Rather',
    text: 'Would you rather relive our first kiss or our best date?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'If you could master one language overnight, which one?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What is one thing about our relationship you\'re genuinely proud of?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'If you had to plan a surprise date for me with only \₹1,000, what would you do?',
  ),
  PartnerQuestion(
    category: '🎭 Hypothetical',
    text: 'If we had to move to another country tomorrow, where would you take me?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'What would our couple\'s secret handshake probably look like?',
  ),
  PartnerQuestion(
    category: '👶 Future',
    text: 'What family tradition would you love for us to create?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What\'s something you believed as a child that makes you laugh now?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What compliment from me has stuck with you the longest?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If our arguments had background music, what genre would they be?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'What\'s one thing I do that instantly gets your attention?',
  ),
  PartnerQuestion(
    category: '🎲 Would You Rather',
    text: 'Would you rather have a fancy dinner or a cozy night with your favorite snacks?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What\'s one ordinary moment with me that secretly means a lot to you?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'If you could have any animal as a ridiculously impractical pet, what would you choose?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If I were a cartoon character, who would I be?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What is one adventure you\'d love us to have together?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What\'s your most oddly specific pet peeve?',
  ),
  PartnerQuestion(
    category: '🎭 Hypothetical',
    text: 'If we won a huge lottery tomorrow, what is the first completely irresponsible thing we\'d buy?',
  ),
  PartnerQuestion(
    category: '👫 Relationship',
    text: 'What\'s something we do differently from other couples that you actually love?',
  ),
  PartnerQuestion(
    category: '🌶️ Playful',
    text: 'What\'s one thing I can do that makes an ordinary evening feel more exciting?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If our relationship were a food, what would it be?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What part of our story would you tell our child first?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'What was your first \'okay, they\'re actually really attractive\' moment with me?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'If you could have dinner with any fictional character, who would you bring home to meet me?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What is your favorite way for us to spend completely unplanned time together?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If we had to compete on a reality show, what would we definitely win at?',
  ),
  PartnerQuestion(
    category: '🎲 Would You Rather',
    text: 'Would you rather receive a surprise gift or a surprise date?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What is something you could talk about for an hour without getting bored?',
  ),
  PartnerQuestion(
    category: '👶 Future',
    text: 'What silly rule do you think we\'d make as parents?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What makes you feel safest with me?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'What kind of compliment from me never gets old?',
  ),
  PartnerQuestion(
    category: '🎭 Hypothetical',
    text: 'If we could pause time for one whole day, how would we spend it?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If I had a completely ridiculous secret talent, what would you guess it is?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What would your dream lazy Sunday with me look like?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'If you could instantly renovate one room in our home, which one would you change first?',
  ),
  PartnerQuestion(
    category: '👫 Relationship',
    text: 'What is one habit of mine you\'ve accidentally started copying?',
  ),
  PartnerQuestion(
    category: '🌶️ Playful',
    text: 'What\'s something spontaneous you\'d love us to do more often?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If our texts were turned into a book, what would the title be?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What\'s one thing you hope never changes about us?',
  ),
  PartnerQuestion(
    category: '🎲 Would You Rather',
    text: 'Would you rather go stargazing together or watch the sunrise together?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What\'s the strangest compliment you\'ve ever received?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'If you had to plan our perfect anniversary with no budget limit, what would you do?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If we had to survive a zombie apocalypse together, who would be in charge and why?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'What\'s a tiny gesture from me that you find surprisingly attractive?',
  ),
  PartnerQuestion(
    category: '🎭 Hypothetical',
    text: 'If we could instantly become experts at something as a couple, what would you choose?',
  ),
  PartnerQuestion(
    category: '👶 Future',
    text: 'What kind of ridiculous nickname do you think we\'d give our child?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'What\'s one thing you\'d happily eat every day for a month?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What is one thing about me that you hope I never doubt?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If our couple had a mascot, what would it be?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What is one place where you\'d love to make a special memory with me?',
  ),
  PartnerQuestion(
    category: '🧠 Random',
    text: 'What\'s a completely silly thing that can instantly improve your mood?',
  ),
  PartnerQuestion(
    category: '😏 Flirty',
    text: 'What\'s one thing about our chemistry that you think other people notice?',
  ),
  PartnerQuestion(
    category: '🎲 Would You Rather',
    text: 'Would you rather have a spontaneous road trip or a surprise staycation?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If we had to invent a holiday just for our relationship, what would we celebrate?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What\'s one moment when you felt especially proud to be my partner?',
  ),
  PartnerQuestion(
    category: '🤯 Random',
    text: 'If you could give me one completely useless superpower, what would it be?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What is one promise you\'d like us to make to each other for the future?',
  ),
  PartnerQuestion(
    category: '🎭 Hypothetical',
    text: 'If we met again for the first time today, where do you think we\'d meet?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If our relationship had a theme song, what would the chorus be about?',
  ),
  PartnerQuestion(
    category: '🌶️ Playful',
    text: 'What\'s one date idea that sounds slightly ridiculous but you\'d actually try with me?',
  ),
  PartnerQuestion(
    category: '👶 Future',
    text: 'What is one thing you hope our family always makes time for?',
  ),
  PartnerQuestion(
    category: '🥹 Sweet',
    text: 'What\'s one reason you\'re glad we found each other?',
  ),
  PartnerQuestion(
    category: '🎲 Would You Rather',
    text: 'Would you rather get 100 tiny surprises from me or one huge surprise?',
  ),
  PartnerQuestion(
    category: '😂 Weird',
    text: 'If we were an old couple in a comedy movie, what would we constantly argue about?',
  ),
  PartnerQuestion(
    category: '💕 Romantic',
    text: 'What is one new thing you\'d love for us to experience together this year?',
  ),
];

PartnerQuestion getRandomPartnerQuestion() {
  return partnerQuestions[Random().nextInt(partnerQuestions.length)];
}
