import 'dart:math';

class FunFact {
  final String emoji;
  final String text;

  const FunFact({
    required this.emoji,
    required this.text,
  });
}

const Map<int, List<FunFact>> motherFunFacts = {
  1: [
    FunFact(
      emoji: '👶',
      text: 'Your pregnancy calendar has a funny little head start: week 1 is counted from the first day of the last menstrual period, even though conception has not happened yet.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your pregnancy calendar has a funny little head start: your pregnancy calendar is already ticking — the usual due date is about 40 weeks from the start of the last period.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your pregnancy calendar has a funny little head start: this week is part of the dating system doctors use to estimate the due date, not a week of fetal development.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your pregnancy calendar has a funny little head start: your future baby\'s story has a calendar that starts a little before conception.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your pregnancy calendar has a funny little head start: pregnancy dating is surprisingly old-school: the clock starts with the last period rather than conception.',
    ),
  ],
  2: [
    FunFact(
      emoji: '👶',
      text: 'Your body is doing some quiet preparation: week 2 is usually when ovulation happens in a typical 28-day cycle — the tiny timing window that can lead to conception.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your body is doing some quiet preparation: the egg is getting ready for its starring moment, while sperm can survive for several days in the reproductive tract.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your body is doing some quiet preparation: pregnancy timing is precise: conception usually happens about two weeks after the last period begins.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your body is doing some quiet preparation: at this point there may be no embryo yet — your body is preparing the conditions for one.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your body is doing some quiet preparation: the famous \'40 weeks\' of pregnancy includes these early calendar weeks before conception.',
    ),
  ],
  3: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s first chapter is starting at microscopic scale: fertilization joins one egg and one sperm into a single cell called a zygote.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s first chapter is starting at microscopic scale: the new zygote starts dividing while traveling toward the uterus — tiny beginnings, lots of cellular teamwork.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s first chapter is starting at microscopic scale: a typical zygote has 46 chromosomes, with 23 coming from each biological parent.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s first chapter is starting at microscopic scale: the early cell cluster is sometimes compared to a tiny raspberry because of its appearance at this stage.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s first chapter is starting at microscopic scale: before there is a recognizable baby shape, an enormous amount of development is already underway at the cellular level.',
    ),
  ],
  4: [
    FunFact(
      emoji: '👶',
      text: 'Inside your body, a major milestone can be happening invisibly: the developing blastocyst can attach itself to the uterine lining in a process called implantation.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Inside your body, a major milestone can be happening invisibly: the inner group of cells will become the embryo, while outer cells contribute to the placenta.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Inside your body, a major milestone can be happening invisibly: the placenta begins its long-term job of supporting the pregnancy surprisingly early.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Inside your body, a major milestone can be happening invisibly: at this stage the future baby is still microscopic, but its basic developmental plan is already being organized.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Inside your body, a major milestone can be happening invisibly: pregnancy can be underway before there is anything remotely baby-shaped to see from the outside.',
    ),
  ],
  5: [
    FunFact(
      emoji: '👶',
      text: 'One tiny pregnancy milestone worth celebrating: pregnancy hormone hCG rises quickly around this stage — it is the hormone detected by pregnancy tests.',
    ),
    FunFact(
      emoji: '✨',
      text: 'One tiny pregnancy milestone worth celebrating: the embryo is organized into three cell layers that will eventually contribute to different parts of the body.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'One tiny pregnancy milestone worth celebrating: one of those layers contributes to the nervous system, skin, eyes and inner ears.',
    ),
    FunFact(
      emoji: '💛',
      text: 'One tiny pregnancy milestone worth celebrating: another layer becomes the foundation for structures including the heart, bones and kidneys.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'One tiny pregnancy milestone worth celebrating: a third layer contributes to organs including the lungs and intestines — one tiny cluster, many future jobs.',
    ),
  ],
  6: [
    FunFact(
      emoji: '👶',
      text: 'Your body is supporting some seriously early construction work: the neural tube, which develops into the brain and spinal cord, is closing around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your body is supporting some seriously early construction work: small arm buds begin appearing — the first hints of future limbs.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your body is supporting some seriously early construction work: structures that will become the eyes and ears are already beginning to develop.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your body is supporting some seriously early construction work: the embryo\'s body has a distinctive C-shaped curve at this point.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your body is supporting some seriously early construction work: the heart and other major organs are starting their early development surprisingly soon after conception.',
    ),
  ],
  7: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s tiny blueprint is getting busier: the brain and face are rapidly developing, while tiny depressions that become the nostrils begin to appear.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s tiny blueprint is getting busier: lower limb buds appear, while the arm buds start looking more like little paddles.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s tiny blueprint is getting busier: the early retina — the light-sensing part of the eye — begins developing.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s tiny blueprint is getting busier: the head is taking center stage because the brain is growing so quickly.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s tiny blueprint is getting busier: those future arms and legs start as surprisingly simple little buds.',
    ),
  ],
  8: [
    FunFact(
      emoji: '👶',
      text: 'A surprisingly detailed little face is taking shape: fingers have begun forming, while the future toes are taking shape.',
    ),
    FunFact(
      emoji: '✨',
      text: 'A surprisingly detailed little face is taking shape: small swellings are forming the future outer parts of the ears.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'A surprisingly detailed little face is taking shape: the nose and upper lip have formed enough to give the face a more recognizable outline.',
    ),
    FunFact(
      emoji: '💛',
      text: 'A surprisingly detailed little face is taking shape: the trunk and neck are beginning to straighten from the earlier C-shaped curve.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'A surprisingly detailed little face is taking shape: by the end of this week, the embryo may be around 11–14 mm from crown to rump.',
    ),
  ],
  9: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s tiny limbs are getting more recognizable: elbows appear as the arms continue developing.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s tiny limbs are getting more recognizable: toes are visible and eyelids are forming.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s tiny limbs are getting more recognizable: the head is still proportionally large because the brain is growing rapidly.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s tiny limbs are getting more recognizable: the arms are getting longer and more defined rather than remaining simple buds.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s tiny limbs are getting more recognizable: your baby\'s face is changing quickly even though the whole body is still very small.',
    ),
  ],
  10: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s hands and feet are becoming more \'baby-like\': fingers and toes are getting longer as the webbing between them disappears.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s hands and feet are becoming more \'baby-like\': the elbows can bend — an early sign that the developing limbs are becoming more complex.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s hands and feet are becoming more \'baby-like\': the outer ears and eyelids continue developing.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s hands and feet are becoming more \'baby-like\': the head is becoming rounder as the early body plan starts looking more familiar.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s hands and feet are becoming more \'baby-like\': by this stage, the tiny hands and feet are already moving toward their recognizable human form.',
    ),
  ],
  11: [
    FunFact(
      emoji: '👶',
      text: 'A lot of tiny details are appearing at once: this is around the point when the developing baby is called a fetus rather than an embryo.',
    ),
    FunFact(
      emoji: '✨',
      text: 'A lot of tiny details are appearing at once: early tooth buds are beginning to appear even though those teeth are nowhere near ready to use.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'A lot of tiny details are appearing at once: red blood cells are beginning to form in the liver.',
    ),
    FunFact(
      emoji: '💛',
      text: 'A lot of tiny details are appearing at once: the outer genital structures are beginning to develop.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'A lot of tiny details are appearing at once: the face is becoming more defined while the eyelids remain fused for now.',
    ),
  ],
  12: [
    FunFact(
      emoji: '👶',
      text: 'Your first-trimester little one is already surprisingly detailed: fingernails are beginning to sprout — tiny details are already being built.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your first-trimester little one is already surprisingly detailed: the face has developed a more recognizable profile.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your first-trimester little one is already surprisingly detailed: the intestines have moved into the abdomen.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your first-trimester little one is already surprisingly detailed: by around this week, the fetus may measure about 6 cm from crown to rump.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your first-trimester little one is already surprisingly detailed: the first trimester is ending with a surprisingly detailed little human form taking shape.',
    ),
  ],
  13: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s skeleton is quietly getting stronger: bones begin hardening, especially in the skull and the long bones of the arms and legs.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s skeleton is quietly getting stronger: the skin is still very thin at this stage, making the developing body look quite delicate.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s skeleton is quietly getting stronger: the skeleton is moving from a soft early framework toward a more solid structure.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s skeleton is quietly getting stronger: your baby\'s body is growing into its proportions while the bones quietly strengthen underneath.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s skeleton is quietly getting stronger: even tiny bones are already following a carefully timed construction schedule.',
    ),
  ],
  14: [
    FunFact(
      emoji: '👶',
      text: 'Your growing baby is entering a fun phase of rapid change: red blood cells are forming in the spleen around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your growing baby is entering a fun phase of rapid change: the neck is becoming more defined, helping the head look less tucked into the body.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your growing baby is entering a fun phase of rapid change: the external anatomy is becoming more developed and may become clearer on imaging.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your growing baby is entering a fun phase of rapid change: the fetus is growing quickly enough that the tiny body is starting to look much more proportional.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your growing baby is entering a fun phase of rapid change: the second trimester is bringing a noticeable shift from \'early blueprint\' to \'growing little person.\'',
    ),
  ],
  15: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s future appearance is already getting little previews: bone development continues, and bones may become visible on ultrasound.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s future appearance is already getting little previews: a scalp-hair pattern is beginning to form.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s future appearance is already getting little previews: the fetus is growing quickly even though many movements are still too subtle to feel.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s future appearance is already getting little previews: the skeleton is getting busier while the outside of the body remains soft.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s future appearance is already getting little previews: your baby\'s future hair pattern is being mapped out long before the first haircut.',
    ),
  ],
  16: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s movement system is becoming more coordinated: the eyes can move slowly even though the eyelids remain closed.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s movement system is becoming more coordinated: the ears are getting close to their final position on the head.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s movement system is becoming more coordinated: limb movements are becoming more coordinated and can be seen during ultrasound.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s movement system is becoming more coordinated: some movements may be happening long before they are strong enough for you to notice.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s movement system is becoming more coordinated: the growing nervous system is helping those tiny arms and legs become better coordinated.',
    ),
  ],
  17: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s tiny movement repertoire is expanding: toenails begin developing.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s tiny movement repertoire is expanding: your baby can become quite active, rolling and flipping even when those movements are not yet felt.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s tiny movement repertoire is expanding: some babies make movements that can produce little hiccup-like jerks.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s tiny movement repertoire is expanding: the skeleton and muscles are becoming a better coordinated team.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s tiny movement repertoire is expanding: your baby\'s movement repertoire is expanding well before the outside world gets to see it.',
    ),
  ],
  18: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s sensory world is getting more interesting: the ears are standing out more from the head.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s sensory world is getting more interesting: your baby may begin to hear sounds around this stage.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s sensory world is getting more interesting: the digestive system has started working.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s sensory world is getting more interesting: movement and hearing are developing together, making the womb a surprisingly busy sensory environment.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s sensory world is getting more interesting: sounds inside the body are part of the environment your baby is beginning to experience.',
    ),
  ],
  19: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s skin has its own protective strategy: vernix caseosa, a creamy protective coating, starts covering the baby\'s skin.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s skin has its own protective strategy: vernix helps protect delicate skin from the long soak in amniotic fluid.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s skin has its own protective strategy: your baby is beginning to contribute urine to the amniotic fluid.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s skin has its own protective strategy: growth can slow a little while the body focuses on maturing its systems.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s skin has its own protective strategy: that white, creamy coating seen on newborns actually starts its story before birth.',
    ),
  ],
  20: [
    FunFact(
      emoji: '👶',
      text: 'Halfway through the calendar, your baby\'s routine is already getting interesting: you\'re around the halfway point of the traditional 40-week pregnancy calendar.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Halfway through the calendar, your baby\'s routine is already getting interesting: many people begin feeling fetal movement around this stage, often called quickening.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Halfway through the calendar, your baby\'s routine is already getting interesting: your baby is regularly cycling between periods of sleep and wakefulness.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Halfway through the calendar, your baby\'s routine is already getting interesting: your baby may respond to noises or your movements with changes in activity.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Halfway through the calendar, your baby\'s routine is already getting interesting: the womb is already a place of movement, rest and sensory experiences — basically a tiny studio apartment with a very busy schedule.',
    ),
  ],
  21: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s reflexes are starting to feel very real: a sucking reflex is developing, and your baby may be able to suck a thumb.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s reflexes are starting to feel very real: fine, downy hair called lanugo covers much of the baby\'s body.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s reflexes are starting to feel very real: lanugo helps hold the protective vernix on the skin.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s reflexes are starting to feel very real: your baby\'s reflexes are becoming more coordinated as the nervous system matures.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s reflexes are starting to feel very real: that classic newborn \'soft fuzz\' has already started growing before birth.',
    ),
  ],
  22: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s face is collecting tiny details: eyebrows and hair become visible around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s face is collecting tiny details: the reproductive organs are becoming more developed.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s face is collecting tiny details: the uterus and ovaries are in place in a developing female fetus.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s face is collecting tiny details: in a developing male fetus, the testes have begun their movement toward the scrotum.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s face is collecting tiny details: your baby\'s face is gaining tiny details — including eyebrows — that will make those future expressions feel familiar.',
    ),
  ],
  23: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s hands and feet are getting uniquely theirs: rapid eye movements can occur even while the eyelids are closed.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s hands and feet are getting uniquely theirs: ridges are forming on the palms and soles that become the foundation for fingerprints and footprints.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s hands and feet are getting uniquely theirs: the lungs are beginning to produce surfactant, which helps air sacs inflate.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s hands and feet are getting uniquely theirs: your baby\'s hands and feet are developing their own unique ridge patterns.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s hands and feet are getting uniquely theirs: those future fingerprints are beginning as tiny raised lines long before anyone can hold that little hand.',
    ),
  ],
  24: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is gradually moving from \'tiny and wrinkly\' toward \'plumper\': the skin is still wrinkled and translucent because there is not much fat underneath yet.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is gradually moving from \'tiny and wrinkly\' toward \'plumper\': the pink or reddish appearance comes partly from blood vessels visible through the thin skin.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is gradually moving from \'tiny and wrinkly\' toward \'plumper\': your baby is gaining weight while the skin gradually becomes less transparent.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is gradually moving from \'tiny and wrinkly\' toward \'plumper\': the body is adding layers: skin, developing fat and increasingly mature organs.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is gradually moving from \'tiny and wrinkly\' toward \'plumper\': those famous chubby cheeks are still a future project — the body is building toward them.',
    ),
  ],
  25: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s world is getting more responsive to sound: your baby may move in response to familiar sounds, including your voice.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s world is getting more responsive to sound: during much of sleep, babies at this stage spend time in REM sleep.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s world is getting more responsive to sound: rEM sleep means the eyes can move quickly even while the eyelids are closed.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s world is getting more responsive to sound: sound is becoming an increasingly interesting part of your baby\'s world.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s world is getting more responsive to sound: your voice can become one of the sounds your baby experiences repeatedly before birth.',
    ),
  ],
  26: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s face is gaining some adorable details: eyebrows and eyelashes have formed.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s face is gaining some adorable details: the eyes are developed, although they may remain closed for a little longer.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s face is gaining some adorable details: your baby\'s features are becoming more detailed while the nervous system continues maturing.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s face is gaining some adorable details: those tiny eyelashes are arriving before the eyes are ready for their big debut.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s face is gaining some adorable details: the face is getting more expressive-looking even though the eyelids are still mostly closed.',
    ),
  ],
  27: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is entering the final big growth stretch: the nervous system continues to mature rapidly.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is entering the final big growth stretch: your baby is gaining more fat, helping the skin become smoother.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is entering the final big growth stretch: movement can feel increasingly purposeful as the nervous system and muscles work together.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is entering the final big growth stretch: this week marks the end of the traditional second trimester.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is entering the final big growth stretch: your baby is moving from rapid early development toward a big final stretch of growth and preparation.',
    ),
  ],
  28: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s body is practicing important after-birth jobs: the eyelids can partially open around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s body is practicing important after-birth jobs: the central nervous system can help regulate body temperature.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s body is practicing important after-birth jobs: breathing-like movements can be seen on ultrasound even though your baby is not breathing air yet.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s body is practicing important after-birth jobs: your baby\'s nervous system is becoming better at coordinating automatic body functions.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s body is practicing important after-birth jobs: the third trimester starts with the body practicing jobs it will need after birth.',
    ),
  ],
  29: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s movements are becoming increasingly coordinated: your baby can kick, stretch and make grasping movements.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s movements are becoming increasingly coordinated: the hands are becoming useful little explorers through movement and touch.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s movements are becoming increasingly coordinated: muscles and the nervous system are practicing coordination together.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s movements are becoming increasingly coordinated: those stretches and kicks are signs of an increasingly coordinated body.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s movements are becoming increasingly coordinated: your baby\'s movement toolkit now includes more than just random wiggles.',
    ),
  ],
  30: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s systems are getting ready for the outside world: the eyes can open wide around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s systems are getting ready for the outside world: some babies already have a noticeable head of hair.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s systems are getting ready for the outside world: red blood cells are now forming in the bone marrow.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s systems are getting ready for the outside world: the body is putting more energy into growth and preparing for life outside the womb.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s systems are getting ready for the outside world: your baby\'s blood-making system is shifting into a more mature workplace: the bone marrow.',
    ),
  ],
  31: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is now in a major \'grow and refine\' phase: most major body development is finished, so much of the remaining pregnancy is about growth and refinement.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is now in a major \'grow and refine\' phase: your baby begins gaining weight more quickly.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is now in a major \'grow and refine\' phase: the brain and nervous system continue making important connections.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is now in a major \'grow and refine\' phase: more body fat is being added to help with temperature control after birth.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is now in a major \'grow and refine\' phase: the final weeks are less about building the basic model and more about upgrading it.',
    ),
  ],
  32: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s newborn look is getting closer: toenails are visible.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s newborn look is getting closer: lanugo, the soft downy hair covering the body, begins to disappear.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s newborn look is getting closer: your baby is continuing to gain weight and fill out.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s newborn look is getting closer: the skin is becoming smoother as fat builds underneath it.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s newborn look is getting closer: that fuzzy newborn look is already being edited down before birth.',
    ),
  ],
  33: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s eyes are doing more than just existing: the pupils can change size in response to light.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s eyes are doing more than just existing: the skull remains flexible even as the bones throughout the body continue hardening.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s eyes are doing more than just existing: your baby\'s eyes are becoming more responsive to the environment.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s eyes are doing more than just existing: the brain and nervous system are helping the eyes perform increasingly sophisticated jobs.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s eyes are doing more than just existing: even before birth, your baby\'s eyes can react to changes in light.',
    ),
  ],
  34: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s tiny details are getting surprisingly finished: fingernails have usually reached the fingertips.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s tiny details are getting surprisingly finished: your baby is continuing to add body fat and weight.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s tiny details are getting surprisingly finished: the body is looking increasingly rounded as the final weeks approach.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s tiny details are getting surprisingly finished: many of the visible details that make a newborn look like a newborn are now in place.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s tiny details are getting surprisingly finished: those tiny fingernails may be surprisingly well developed before the first cuddle.',
    ),
  ],
  35: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s space is getting snug: your baby fills most of the amniotic sac, so there is less room for giant acrobatics.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s space is getting snug: even with less space, stretches, rolls and wiggles can still be noticeable.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s space is getting snug: your baby\'s movements may feel different as the available space gets tighter.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s space is getting snug: the womb is becoming a snugger apartment as your baby grows.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s space is getting snug: big flips may give way to more noticeable rolls and stretches simply because space is getting precious.',
    ),
  ],
  36: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is getting that classic newborn softness: your baby\'s skin is becoming smoother as more fat builds underneath it.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is getting that classic newborn softness: the limbs start looking chubbier as the body stores more fat.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is getting that classic newborn softness: most babies have turned head-down by around this point, although not every baby does.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is getting that classic newborn softness: the body is adding the soft padding that helps with temperature control after birth.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is getting that classic newborn softness: your baby\'s final weeks are increasingly about getting plump, strong and ready.',
    ),
  ],
  37: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is getting serious about the final approach: your baby can grasp things firmly.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is getting serious about the final approach: the head may begin moving down into the pelvis as the body prepares for birth.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is getting serious about the final approach: at 37 weeks, the pregnancy has reached the early-term stage.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is getting serious about the final approach: the hands have become strong enough for a surprisingly good little grip.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is getting serious about the final approach: your baby\'s body is shifting from \'still growing\' toward \'getting ready to meet you.\'',
    ),
  ],
  38: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s tiny finishing details are nearly complete: toenails have reached the tips of the toes.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s tiny finishing details are nearly complete: most of the lanugo has disappeared by around this stage.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s tiny finishing details are nearly complete: the head and belly measurements are becoming more similar in proportion.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s tiny finishing details are nearly complete: your baby is continuing to add fat for warmth after birth.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s tiny finishing details are nearly complete: those tiny toenails have been growing quietly for months and can now reach the toe tips.',
    ),
  ],
  39: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is officially in the full-term home stretch: at 39 weeks, the baby is considered full term.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is officially in the full-term home stretch: more body fat is being added to help keep your newborn warm.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is officially in the full-term home stretch: the chest is getting larger as the body finishes its final preparations.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is officially in the full-term home stretch: your baby\'s basic systems are ready for life outside the womb, while final growth continues.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is officially in the full-term home stretch: after months of building, the last stretch is largely about finishing touches and getting ready for the big transition.',
    ),
  ],
  40: [
    FunFact(
      emoji: '👶',
      text: 'Your pregnancy calendar has reached its famous final week: week 40 is the traditional estimated due-date week — but a due date is an estimate, not a guaranteed arrival date.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your pregnancy calendar has reached its famous final week: healthy babies come in many different sizes, so one baby\'s measurements can look quite different from another\'s.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your pregnancy calendar has reached its famous final week: your baby has spent months building and practicing systems needed for life outside the womb.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your pregnancy calendar has reached its famous final week: at this point, the countdown has turned into a \'whenever you\'re ready\' situation for your baby.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your pregnancy calendar has reached its famous final week: the end of the 40-week calendar is not a deadline — babies can arrive before or after the estimated due date.',
    ),
  ],
};

const Map<int, List<FunFact>> fatherFunFacts = {
  1: [
    FunFact(
      emoji: '👶',
      text: 'A fun thing for dads-to-be to know: week 1 is counted from the first day of the last menstrual period, even though conception has not happened yet.',
    ),
    FunFact(
      emoji: '✨',
      text: 'A fun thing for dads-to-be to know: your pregnancy calendar is already ticking — the usual due date is about 40 weeks from the start of the last period.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'A fun thing for dads-to-be to know: this week is part of the dating system doctors use to estimate the due date, not a week of fetal development.',
    ),
    FunFact(
      emoji: '💛',
      text: 'A fun thing for dads-to-be to know: your future baby\'s story has a calendar that starts a little before conception.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'A fun thing for dads-to-be to know: pregnancy dating is surprisingly old-school: the clock starts with the last period rather than conception.',
    ),
  ],
  2: [
    FunFact(
      emoji: '👶',
      text: 'Here\'s a surprisingly early dad fact: week 2 is usually when ovulation happens in a typical 28-day cycle — the tiny timing window that can lead to conception.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Here\'s a surprisingly early dad fact: the egg is getting ready for its starring moment, while sperm can survive for several days in the reproductive tract.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Here\'s a surprisingly early dad fact: pregnancy timing is precise: conception usually happens about two weeks after the last period begins.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Here\'s a surprisingly early dad fact: at this point there may be no embryo yet — your body is preparing the conditions for one.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Here\'s a surprisingly early dad fact: the famous \'40 weeks\' of pregnancy includes these early calendar weeks before conception.',
    ),
  ],
  3: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s story starts with some serious cellular teamwork: fertilization joins one egg and one sperm into a single cell called a zygote.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s story starts with some serious cellular teamwork: the new zygote starts dividing while traveling toward the uterus — tiny beginnings, lots of cellular teamwork.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s story starts with some serious cellular teamwork: a typical zygote has 46 chromosomes, with 23 coming from each biological parent.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s story starts with some serious cellular teamwork: the early cell cluster is sometimes compared to a tiny raspberry because of its appearance at this stage.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s story starts with some serious cellular teamwork: before there is a recognizable baby shape, an enormous amount of development is already underway at the cellular level.',
    ),
  ],
  4: [
    FunFact(
      emoji: '👶',
      text: 'Even before there\'s a bump to talk about, this can be happening: the developing blastocyst can attach itself to the uterine lining in a process called implantation.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Even before there\'s a bump to talk about, this can be happening: the inner group of cells will become the embryo, while outer cells contribute to the placenta.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Even before there\'s a bump to talk about, this can be happening: the placenta begins its long-term job of supporting the pregnancy surprisingly early.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Even before there\'s a bump to talk about, this can be happening: at this stage the future baby is still microscopic, but its basic developmental plan is already being organized.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Even before there\'s a bump to talk about, this can be happening: pregnancy can be underway before there is anything remotely baby-shaped to see from the outside.',
    ),
  ],
  5: [
    FunFact(
      emoji: '👶',
      text: 'Your tiny future teammate is already following a complex plan: pregnancy hormone hCG rises quickly around this stage — it is the hormone detected by pregnancy tests.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your tiny future teammate is already following a complex plan: the embryo is organized into three cell layers that will eventually contribute to different parts of the body.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your tiny future teammate is already following a complex plan: one of those layers contributes to the nervous system, skin, eyes and inner ears.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your tiny future teammate is already following a complex plan: another layer becomes the foundation for structures including the heart, bones and kidneys.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your tiny future teammate is already following a complex plan: a third layer contributes to organs including the lungs and intestines — one tiny cluster, many future jobs.',
    ),
  ],
  6: [
    FunFact(
      emoji: '👶',
      text: 'There\'s a lot happening before a first photo: the neural tube, which develops into the brain and spinal cord, is closing around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'There\'s a lot happening before a first photo: small arm buds begin appearing — the first hints of future limbs.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'There\'s a lot happening before a first photo: structures that will become the eyes and ears are already beginning to develop.',
    ),
    FunFact(
      emoji: '💛',
      text: 'There\'s a lot happening before a first photo: the embryo\'s body has a distinctive C-shaped curve at this point.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'There\'s a lot happening before a first photo: the heart and other major organs are starting their early development surprisingly soon after conception.',
    ),
  ],
  7: [
    FunFact(
      emoji: '👶',
      text: 'Your future baby\'s head is already doing most of the development work: the brain and face are rapidly developing, while tiny depressions that become the nostrils begin to appear.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your future baby\'s head is already doing most of the development work: lower limb buds appear, while the arm buds start looking more like little paddles.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your future baby\'s head is already doing most of the development work: the early retina — the light-sensing part of the eye — begins developing.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your future baby\'s head is already doing most of the development work: the head is taking center stage because the brain is growing so quickly.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your future baby\'s head is already doing most of the development work: those future arms and legs start as surprisingly simple little buds.',
    ),
  ],
  8: [
    FunFact(
      emoji: '👶',
      text: 'Those future little hands and feet have humble beginnings: fingers have begun forming, while the future toes are taking shape.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Those future little hands and feet have humble beginnings: small swellings are forming the future outer parts of the ears.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Those future little hands and feet have humble beginnings: the nose and upper lip have formed enough to give the face a more recognizable outline.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Those future little hands and feet have humble beginnings: the trunk and neck are beginning to straighten from the earlier C-shaped curve.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Those future little hands and feet have humble beginnings: by the end of this week, the embryo may be around 11–14 mm from crown to rump.',
    ),
  ],
  9: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s tiny limbs are becoming surprisingly sophisticated: elbows appear as the arms continue developing.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s tiny limbs are becoming surprisingly sophisticated: toes are visible and eyelids are forming.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s tiny limbs are becoming surprisingly sophisticated: the head is still proportionally large because the brain is growing rapidly.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s tiny limbs are becoming surprisingly sophisticated: the arms are getting longer and more defined rather than remaining simple buds.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s tiny limbs are becoming surprisingly sophisticated: your baby\'s face is changing quickly even though the whole body is still very small.',
    ),
  ],
  10: [
    FunFact(
      emoji: '👶',
      text: 'The tiny body is already learning some impressive tricks: fingers and toes are getting longer as the webbing between them disappears.',
    ),
    FunFact(
      emoji: '✨',
      text: 'The tiny body is already learning some impressive tricks: the elbows can bend — an early sign that the developing limbs are becoming more complex.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'The tiny body is already learning some impressive tricks: the outer ears and eyelids continue developing.',
    ),
    FunFact(
      emoji: '💛',
      text: 'The tiny body is already learning some impressive tricks: the head is becoming rounder as the early body plan starts looking more familiar.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'The tiny body is already learning some impressive tricks: by this stage, the tiny hands and feet are already moving toward their recognizable human form.',
    ),
  ],
  11: [
    FunFact(
      emoji: '👶',
      text: 'Your future baby\'s feature list is growing fast: this is around the point when the developing baby is called a fetus rather than an embryo.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your future baby\'s feature list is growing fast: early tooth buds are beginning to appear even though those teeth are nowhere near ready to use.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your future baby\'s feature list is growing fast: red blood cells are beginning to form in the liver.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your future baby\'s feature list is growing fast: the outer genital structures are beginning to develop.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your future baby\'s feature list is growing fast: the face is becoming more defined while the eyelids remain fused for now.',
    ),
  ],
  12: [
    FunFact(
      emoji: '👶',
      text: 'Your little one is finishing the first trimester with a lot going on: fingernails are beginning to sprout — tiny details are already being built.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your little one is finishing the first trimester with a lot going on: the face has developed a more recognizable profile.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your little one is finishing the first trimester with a lot going on: the intestines have moved into the abdomen.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your little one is finishing the first trimester with a lot going on: by around this week, the fetus may measure about 6 cm from crown to rump.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your little one is finishing the first trimester with a lot going on: the first trimester is ending with a surprisingly detailed little human form taking shape.',
    ),
  ],
  13: [
    FunFact(
      emoji: '👶',
      text: 'The skeleton crew is officially under construction: bones begin hardening, especially in the skull and the long bones of the arms and legs.',
    ),
    FunFact(
      emoji: '✨',
      text: 'The skeleton crew is officially under construction: the skin is still very thin at this stage, making the developing body look quite delicate.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'The skeleton crew is officially under construction: the skeleton is moving from a soft early framework toward a more solid structure.',
    ),
    FunFact(
      emoji: '💛',
      text: 'The skeleton crew is officially under construction: your baby\'s body is growing into its proportions while the bones quietly strengthen underneath.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'The skeleton crew is officially under construction: even tiny bones are already following a carefully timed construction schedule.',
    ),
  ],
  14: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s proportions are changing quickly now: red blood cells are forming in the spleen around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s proportions are changing quickly now: the neck is becoming more defined, helping the head look less tucked into the body.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s proportions are changing quickly now: the external anatomy is becoming more developed and may become clearer on imaging.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s proportions are changing quickly now: the fetus is growing quickly enough that the tiny body is starting to look much more proportional.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s proportions are changing quickly now: the second trimester is bringing a noticeable shift from \'early blueprint\' to \'growing little person.\'',
    ),
  ],
  15: [
    FunFact(
      emoji: '👶',
      text: 'Your future baby\'s appearance is already getting some early signatures: bone development continues, and bones may become visible on ultrasound.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your future baby\'s appearance is already getting some early signatures: a scalp-hair pattern is beginning to form.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your future baby\'s appearance is already getting some early signatures: the fetus is growing quickly even though many movements are still too subtle to feel.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your future baby\'s appearance is already getting some early signatures: the skeleton is getting busier while the outside of the body remains soft.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your future baby\'s appearance is already getting some early signatures: your baby\'s future hair pattern is being mapped out long before the first haircut.',
    ),
  ],
  16: [
    FunFact(
      emoji: '👶',
      text: 'Your little one\'s movement system is leveling up: the eyes can move slowly even though the eyelids remain closed.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your little one\'s movement system is leveling up: the ears are getting close to their final position on the head.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your little one\'s movement system is leveling up: limb movements are becoming more coordinated and can be seen during ultrasound.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your little one\'s movement system is leveling up: some movements may be happening long before they are strong enough for you to notice.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your little one\'s movement system is leveling up: the growing nervous system is helping those tiny arms and legs become better coordinated.',
    ),
  ],
  17: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is getting more athletic by the week: toenails begin developing.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is getting more athletic by the week: your baby can become quite active, rolling and flipping even when those movements are not yet felt.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is getting more athletic by the week: some babies make movements that can produce little hiccup-like jerks.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is getting more athletic by the week: the skeleton and muscles are becoming a better coordinated team.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is getting more athletic by the week: your baby\'s movement repertoire is expanding well before the outside world gets to see it.',
    ),
  ],
  18: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s ears are joining the conversation: the ears are standing out more from the head.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s ears are joining the conversation: your baby may begin to hear sounds around this stage.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s ears are joining the conversation: the digestive system has started working.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s ears are joining the conversation: movement and hearing are developing together, making the womb a surprisingly busy sensory environment.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s ears are joining the conversation: sounds inside the body are part of the environment your baby is beginning to experience.',
    ),
  ],
  19: [
    FunFact(
      emoji: '👶',
      text: 'Your baby has already invented a skin-care routine: vernix caseosa, a creamy protective coating, starts covering the baby\'s skin.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby has already invented a skin-care routine: vernix helps protect delicate skin from the long soak in amniotic fluid.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby has already invented a skin-care routine: your baby is beginning to contribute urine to the amniotic fluid.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby has already invented a skin-care routine: growth can slow a little while the body focuses on maturing its systems.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby has already invented a skin-care routine: that white, creamy coating seen on newborns actually starts its story before birth.',
    ),
  ],
  20: [
    FunFact(
      emoji: '👶',
      text: 'Halfway there, and your baby already has a sleep-and-wake rhythm: you\'re around the halfway point of the traditional 40-week pregnancy calendar.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Halfway there, and your baby already has a sleep-and-wake rhythm: many people begin feeling fetal movement around this stage, often called quickening.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Halfway there, and your baby already has a sleep-and-wake rhythm: your baby is regularly cycling between periods of sleep and wakefulness.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Halfway there, and your baby already has a sleep-and-wake rhythm: your baby may respond to noises or your movements with changes in activity.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Halfway there, and your baby already has a sleep-and-wake rhythm: the womb is already a place of movement, rest and sensory experiences — basically a tiny studio apartment with a very busy schedule.',
    ),
  ],
  21: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s reflexes are becoming more interesting: a sucking reflex is developing, and your baby may be able to suck a thumb.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s reflexes are becoming more interesting: fine, downy hair called lanugo covers much of the baby\'s body.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s reflexes are becoming more interesting: lanugo helps hold the protective vernix on the skin.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s reflexes are becoming more interesting: your baby\'s reflexes are becoming more coordinated as the nervous system matures.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s reflexes are becoming more interesting: that classic newborn \'soft fuzz\' has already started growing before birth.',
    ),
  ],
  22: [
    FunFact(
      emoji: '👶',
      text: 'Your future baby\'s face is picking up tiny details: eyebrows and hair become visible around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your future baby\'s face is picking up tiny details: the reproductive organs are becoming more developed.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your future baby\'s face is picking up tiny details: the uterus and ovaries are in place in a developing female fetus.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your future baby\'s face is picking up tiny details: in a developing male fetus, the testes have begun their movement toward the scrotum.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your future baby\'s face is picking up tiny details: your baby\'s face is gaining tiny details — including eyebrows — that will make those future expressions feel familiar.',
    ),
  ],
  23: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s hands and feet are getting their own identity: rapid eye movements can occur even while the eyelids are closed.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s hands and feet are getting their own identity: ridges are forming on the palms and soles that become the foundation for fingerprints and footprints.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s hands and feet are getting their own identity: the lungs are beginning to produce surfactant, which helps air sacs inflate.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s hands and feet are getting their own identity: your baby\'s hands and feet are developing their own unique ridge patterns.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s hands and feet are getting their own identity: those future fingerprints are beginning as tiny raised lines long before anyone can hold that little hand.',
    ),
  ],
  24: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is still wrinkly now, but the filling-out phase is underway: the skin is still wrinkled and translucent because there is not much fat underneath yet.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is still wrinkly now, but the filling-out phase is underway: the pink or reddish appearance comes partly from blood vessels visible through the thin skin.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is still wrinkly now, but the filling-out phase is underway: your baby is gaining weight while the skin gradually becomes less transparent.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is still wrinkly now, but the filling-out phase is underway: the body is adding layers: skin, developing fat and increasingly mature organs.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is still wrinkly now, but the filling-out phase is underway: those famous chubby cheeks are still a future project — the body is building toward them.',
    ),
  ],
  25: [
    FunFact(
      emoji: '👶',
      text: 'Your voice is becoming part of your baby\'s soundscape: your baby may move in response to familiar sounds, including your voice.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your voice is becoming part of your baby\'s soundscape: during much of sleep, babies at this stage spend time in REM sleep.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your voice is becoming part of your baby\'s soundscape: rEM sleep means the eyes can move quickly even while the eyelids are closed.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your voice is becoming part of your baby\'s soundscape: sound is becoming an increasingly interesting part of your baby\'s world.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your voice is becoming part of your baby\'s soundscape: your voice can become one of the sounds your baby experiences repeatedly before birth.',
    ),
  ],
  26: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s face is looking more finished every week: eyebrows and eyelashes have formed.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s face is looking more finished every week: the eyes are developed, although they may remain closed for a little longer.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s face is looking more finished every week: your baby\'s features are becoming more detailed while the nervous system continues maturing.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s face is looking more finished every week: those tiny eyelashes are arriving before the eyes are ready for their big debut.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s face is looking more finished every week: the face is getting more expressive-looking even though the eyelids are still mostly closed.',
    ),
  ],
  27: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is moving into the final stretch of development: the nervous system continues to mature rapidly.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is moving into the final stretch of development: your baby is gaining more fat, helping the skin become smoother.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is moving into the final stretch of development: movement can feel increasingly purposeful as the nervous system and muscles work together.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is moving into the final stretch of development: this week marks the end of the traditional second trimester.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is moving into the final stretch of development: your baby is moving from rapid early development toward a big final stretch of growth and preparation.',
    ),
  ],
  28: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s nervous system is practicing for life outside: the eyelids can partially open around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s nervous system is practicing for life outside: the central nervous system can help regulate body temperature.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s nervous system is practicing for life outside: breathing-like movements can be seen on ultrasound even though your baby is not breathing air yet.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s nervous system is practicing for life outside: your baby\'s nervous system is becoming better at coordinating automatic body functions.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s nervous system is practicing for life outside: the third trimester starts with the body practicing jobs it will need after birth.',
    ),
  ],
  29: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s movement toolkit is getting impressive: your baby can kick, stretch and make grasping movements.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s movement toolkit is getting impressive: the hands are becoming useful little explorers through movement and touch.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s movement toolkit is getting impressive: muscles and the nervous system are practicing coordination together.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s movement toolkit is getting impressive: those stretches and kicks are signs of an increasingly coordinated body.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s movement toolkit is getting impressive: your baby\'s movement toolkit now includes more than just random wiggles.',
    ),
  ],
  30: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s body is entering serious preparation mode: the eyes can open wide around this stage.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s body is entering serious preparation mode: some babies already have a noticeable head of hair.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s body is entering serious preparation mode: red blood cells are now forming in the bone marrow.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s body is entering serious preparation mode: the body is putting more energy into growth and preparing for life outside the womb.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s body is entering serious preparation mode: your baby\'s blood-making system is shifting into a more mature workplace: the bone marrow.',
    ),
  ],
  31: [
    FunFact(
      emoji: '👶',
      text: 'Think of this stage as the final upgrade cycle: most major body development is finished, so much of the remaining pregnancy is about growth and refinement.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Think of this stage as the final upgrade cycle: your baby begins gaining weight more quickly.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Think of this stage as the final upgrade cycle: the brain and nervous system continue making important connections.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Think of this stage as the final upgrade cycle: more body fat is being added to help with temperature control after birth.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Think of this stage as the final upgrade cycle: the final weeks are less about building the basic model and more about upgrading it.',
    ),
  ],
  32: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s newborn look is coming into focus: toenails are visible.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s newborn look is coming into focus: lanugo, the soft downy hair covering the body, begins to disappear.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s newborn look is coming into focus: your baby is continuing to gain weight and fill out.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s newborn look is coming into focus: the skin is becoming smoother as fat builds underneath it.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s newborn look is coming into focus: that fuzzy newborn look is already being edited down before birth.',
    ),
  ],
  33: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s eyes can already react to light: the pupils can change size in response to light.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s eyes can already react to light: the skull remains flexible even as the bones throughout the body continue hardening.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s eyes can already react to light: your baby\'s eyes are becoming more responsive to the environment.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s eyes can already react to light: the brain and nervous system are helping the eyes perform increasingly sophisticated jobs.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s eyes can already react to light: even before birth, your baby\'s eyes can react to changes in light.',
    ),
  ],
  34: [
    FunFact(
      emoji: '👶',
      text: 'Those tiny fingernails are nearly at the finish line: fingernails have usually reached the fingertips.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Those tiny fingernails are nearly at the finish line: your baby is continuing to add body fat and weight.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Those tiny fingernails are nearly at the finish line: the body is looking increasingly rounded as the final weeks approach.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Those tiny fingernails are nearly at the finish line: many of the visible details that make a newborn look like a newborn are now in place.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Those tiny fingernails are nearly at the finish line: those tiny fingernails may be surprisingly well developed before the first cuddle.',
    ),
  ],
  35: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s apartment is getting very cozy: your baby fills most of the amniotic sac, so there is less room for giant acrobatics.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s apartment is getting very cozy: even with less space, stretches, rolls and wiggles can still be noticeable.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s apartment is getting very cozy: your baby\'s movements may feel different as the available space gets tighter.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s apartment is getting very cozy: the womb is becoming a snugger apartment as your baby grows.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s apartment is getting very cozy: big flips may give way to more noticeable rolls and stretches simply because space is getting precious.',
    ),
  ],
  36: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is adding the final layers of newborn softness: your baby\'s skin is becoming smoother as more fat builds underneath it.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is adding the final layers of newborn softness: the limbs start looking chubbier as the body stores more fat.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is adding the final layers of newborn softness: most babies have turned head-down by around this point, although not every baby does.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is adding the final layers of newborn softness: the body is adding the soft padding that helps with temperature control after birth.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is adding the final layers of newborn softness: your baby\'s final weeks are increasingly about getting plump, strong and ready.',
    ),
  ],
  37: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is getting into launch position: your baby can grasp things firmly.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is getting into launch position: the head may begin moving down into the pelvis as the body prepares for birth.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is getting into launch position: at 37 weeks, the pregnancy has reached the early-term stage.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is getting into launch position: the hands have become strong enough for a surprisingly good little grip.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is getting into launch position: your baby\'s body is shifting from \'still growing\' toward \'getting ready to meet you.\'',
    ),
  ],
  38: [
    FunFact(
      emoji: '👶',
      text: 'Your baby\'s tiny finishing touches are almost done: toenails have reached the tips of the toes.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby\'s tiny finishing touches are almost done: most of the lanugo has disappeared by around this stage.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby\'s tiny finishing touches are almost done: the head and belly measurements are becoming more similar in proportion.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby\'s tiny finishing touches are almost done: your baby is continuing to add fat for warmth after birth.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby\'s tiny finishing touches are almost done: those tiny toenails have been growing quietly for months and can now reach the toe tips.',
    ),
  ],
  39: [
    FunFact(
      emoji: '👶',
      text: 'Your baby is officially full term and nearly ready for the big reveal: at 39 weeks, the baby is considered full term.',
    ),
    FunFact(
      emoji: '✨',
      text: 'Your baby is officially full term and nearly ready for the big reveal: more body fat is being added to help keep your newborn warm.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'Your baby is officially full term and nearly ready for the big reveal: the chest is getting larger as the body finishes its final preparations.',
    ),
    FunFact(
      emoji: '💛',
      text: 'Your baby is officially full term and nearly ready for the big reveal: your baby\'s basic systems are ready for life outside the womb, while final growth continues.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'Your baby is officially full term and nearly ready for the big reveal: after months of building, the last stretch is largely about finishing touches and getting ready for the big transition.',
    ),
  ],
  40: [
    FunFact(
      emoji: '👶',
      text: 'The due-date week is here — but your baby still gets to choose the exact arrival time: week 40 is the traditional estimated due-date week — but a due date is an estimate, not a guaranteed arrival date.',
    ),
    FunFact(
      emoji: '✨',
      text: 'The due-date week is here — but your baby still gets to choose the exact arrival time: healthy babies come in many different sizes, so one baby\'s measurements can look quite different from another\'s.',
    ),
    FunFact(
      emoji: '🧠',
      text: 'The due-date week is here — but your baby still gets to choose the exact arrival time: your baby has spent months building and practicing systems needed for life outside the womb.',
    ),
    FunFact(
      emoji: '💛',
      text: 'The due-date week is here — but your baby still gets to choose the exact arrival time: at this point, the countdown has turned into a \'whenever you\'re ready\' situation for your baby.',
    ),
    FunFact(
      emoji: '🌱',
      text: 'The due-date week is here — but your baby still gets to choose the exact arrival time: the end of the 40-week calendar is not a deadline — babies can arrive before or after the estimated due date.',
    ),
  ],
};

FunFact? getRandomFunFact(
  int week, {
  required bool isFather,
}) {
  final facts = isFather ? fatherFunFacts[week] : motherFunFacts[week];

  if (facts == null || facts.isEmpty) {
    return null;
  }

  return facts[Random().nextInt(facts.length)];
}
