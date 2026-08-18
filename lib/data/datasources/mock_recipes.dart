import '../models/localized_text.dart';
import '../models/recipe.dart';
import '../../core/theme/app_semantic_colors.dart';

/// 11 recipes, in the color/order pattern observed in the reference
/// design: red, orange, plain, plain, red, orange, yellow, teal, pink,
/// orange, plain — with full English + Arabic content for every field.
final List<Recipe> mockRecipes = [
  Recipe(
    id: 'strawberries',
    title: const LocalizedText(en: 'Strawberries', ar: 'الفراولة'),
    shortDescription: const LocalizedText(
      en: "We'll admit it: we go a little crazy during strawberry season. Though easy to enjoy on their own...",
      ar: 'نعترف أننا نُصاب بجنون خفيف في موسم الفراولة. ورغم سهولة الاستمتاع بها وحدها...',
    ),
    fullDescription: const LocalizedText(
      en: "We'll admit it: we go a little crazy during strawberry season. Though easy to enjoy on their own, "
          'strawberries shine brightest when folded into a light, barely-sweet cream and piled high on a buttery shortcake.',
      ar: 'نعترف أننا نُصاب بجنون خفيف في موسم الفراولة. ورغم سهولة الاستمتاع بها كما هي، تتألق الفراولة أكثر '
          'عندما تُمزج مع كريمة خفيفة قليلة السكر وتُكدّس فوق كيك زبدة طرية.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1543528176-61b239494933?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.red,
    hasCardColor: true,
    category: RecipeCategory.cold,
    prepMinutes: 20,
    servings: 4,
    ingredients: const [
      Ingredient(LocalizedText(en: '500g fresh strawberries', ar: '500 غرام فراولة طازجة')),
      Ingredient(LocalizedText(en: '2 tbsp caster sugar', ar: 'ملعقتان كبيرتان سكر ناعم')),
      Ingredient(LocalizedText(en: '1 lemon, juiced', ar: 'عصير ليمونة واحدة')),
      Ingredient(LocalizedText(en: '250ml double cream', ar: '250 مل كريمة خفق كثيفة')),
      Ingredient(LocalizedText(en: '4 shortcake biscuits', ar: '4 قطع بسكويت شورت كيك')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Hull and slice the strawberries, then toss with sugar and lemon juice. Let macerate for 15 minutes.',
        ar: 'نظّفي الفراولة وقطّعيها شرائح، ثم اخلطيها مع السكر وعصير الليمون واتركيها ترتاح 15 دقيقة.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Whip the cream to soft peaks and fold in two tablespoons of the strawberry juice.',
        ar: 'اخفقي الكريمة حتى تتماسك قليلًا، ثم أضيفي إليها ملعقتين كبيرتين من عصير الفراولة.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Layer the shortcakes with cream and strawberries, finishing with a spoonful of juice on top.',
        ar: 'رصّي طبقات الشورت كيك مع الكريمة والفراولة، وأنهي بملعقة من العصير فوق الطبق.',
      )),
    ],
  ),
  Recipe(
    id: 'chocolate_cake',
    title: const LocalizedText(en: 'Chocolate Cake', ar: 'كيك الشوكولاتة'),
    shortDescription: const LocalizedText(
      en: 'The Best Chocolate Cake Recipe - A one bowl chocolate cake recipe that is rich, moist and easy...',
      ar: 'أفضل وصفة كيك شوكولاتة - وصفة بوعاء واحد، غنية وطرية وسهلة التحضير...',
    ),
    fullDescription: const LocalizedText(
      en: 'The Best Chocolate Cake Recipe — a one-bowl chocolate cake that is rich, moist and easy to make. '
          'Topped with a silky chocolate ganache and fresh berries for a bakery-style finish.',
      ar: 'أفضل وصفة كيك شوكولاتة — كيك بوعاء واحد غني وطري وسهل التحضير، '
          'مغطى بطبقة ملساء من الغاناش وحبات توت طازجة للمسة احترافية شبيهة بالمخابز.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.orange,
    hasCardColor: true,
    category: RecipeCategory.cake,
    prepMinutes: 55,
    servings: 8,
    ingredients: const [
      Ingredient(LocalizedText(en: '200g dark chocolate', ar: '200 غرام شوكولاتة داكنة')),
      Ingredient(LocalizedText(en: '250g unsalted butter', ar: '250 غرام زبدة غير مملحة')),
      Ingredient(LocalizedText(en: '300g caster sugar', ar: '300 غرام سكر ناعم')),
      Ingredient(LocalizedText(en: '4 large eggs', ar: '4 بيضات كبيرة')),
      Ingredient(LocalizedText(en: '220g plain flour', ar: '220 غرام دقيق أبيض')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Melt the chocolate and butter together over a bain-marie, then set aside to cool slightly.',
        ar: 'ذوّبي الشوكولاتة والزبدة معًا على حمام مائي، ثم اتركيهما جانبًا ليبردا قليلًا.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Whisk the sugar and eggs until pale, then fold in the chocolate mixture and flour.',
        ar: 'اخفقي السكر والبيض حتى يصبح اللون فاتحًا، ثم أضيفي خليط الشوكولاتة والدقيق.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Bake at 170°C for 35-40 minutes, then cool completely before glazing with ganache.',
        ar: 'اخبزي على حرارة 170° لمدة 35-40 دقيقة، ثم اتركيه يبرد تمامًا قبل تغطيته بالغاناش.',
      )),
    ],
  ),
  Recipe(
    id: 'apple_pie',
    title: const LocalizedText(en: 'Apple Pie', ar: 'فطيرة التفاح'),
    shortDescription: const LocalizedText(
      en: "This was my grandmother's apple pie recipe. I have never seen another one quite like it...",
      ar: 'هذه كانت وصفة فطيرة التفاح الخاصة بجدتي. لم أرَ وصفة أخرى تشبهها تمامًا...',
    ),
    fullDescription: const LocalizedText(
      en: "This was my grandmother's apple pie recipe. I have never seen another one quite like it — "
          'a lattice crust, warm cinnamon-spiced apples, and a hint of nutmeg that makes the whole kitchen smell like autumn.',
      ar: 'هذه كانت وصفة فطيرة التفاح الخاصة بجدتي. لم أرَ وصفة أخرى تشبهها تمامًا — '
          'عجينة متشابكة، وتفاح دافئ منكّه بالقرفة، ولمسة من جوزة الطيب تملأ المطبخ برائحة الخريف.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1568571780765-9276ac8b75a2?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.orange,
    hasCardColor: false,
    category: RecipeCategory.pie,
    prepMinutes: 70,
    servings: 8,
    ingredients: const [
      Ingredient(LocalizedText(en: '6 apples, peeled and sliced', ar: '6 حبات تفاح مقشرة ومقطعة')),
      Ingredient(LocalizedText(en: '150g brown sugar', ar: '150 غرام سكر بني')),
      Ingredient(LocalizedText(en: '1 tsp cinnamon', ar: 'ملعقة صغيرة قرفة')),
      Ingredient(LocalizedText(en: '2 pie crusts', ar: 'قرصا عجين للفطيرة')),
      Ingredient(LocalizedText(en: '1 egg, beaten (for wash)', ar: 'بيضة مخفوقة (للدهن)')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Toss the sliced apples with sugar, cinnamon and a pinch of salt.',
        ar: 'اخلطي شرائح التفاح مع السكر والقرفة ورشة ملح.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Line a pie dish with the first crust and fill with the apple mixture.',
        ar: 'افرشي طبق الفطيرة بالعجينة الأولى واملئيه بخليط التفاح.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Top with a lattice crust, brush with egg wash and bake at 190°C for 50 minutes.',
        ar: 'غطّي بعجينة متشابكة، ادهنيها بالبيضة، واخبزي على حرارة 190° لمدة 50 دقيقة.',
      )),
    ],
  ),
  Recipe(
    id: 'chocolate_donuts',
    title: const LocalizedText(en: 'Chocolate Donuts', ar: 'دونات الشوكولاتة'),
    shortDescription: const LocalizedText(
      en: 'Multi bakers around the world are obsessed with these light, fluffy and full of chocolate donuts...',
      ar: 'خبازون حول العالم مهووسون بهذه الدونات الخفيفة الطرية المليئة بالشوكولاتة...',
    ),
    fullDescription: const LocalizedText(
      en: 'Bakers around the world are obsessed with these light, fluffy donuts, generously dipped in glossy '
          'chocolate glaze and finished with a scattering of crushed pistachios.',
      ar: 'خبازون حول العالم مهووسون بهذه الدونات الخفيفة الطرية، المغموسة بسخاء في تغطية شوكولاتة لامعة '
          'والمزيّنة برشة من الفستق المطحون.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.red,
    hasCardColor: false,
    category: RecipeCategory.cake,
    prepMinutes: 90,
    servings: 10,
    ingredients: const [
      Ingredient(LocalizedText(en: '300g strong white flour', ar: '300 غرام دقيق أبيض قوي')),
      Ingredient(LocalizedText(en: '7g instant yeast', ar: '7 غرام خميرة فورية')),
      Ingredient(LocalizedText(en: '40g caster sugar', ar: '40 غرام سكر ناعم')),
      Ingredient(LocalizedText(en: '2 eggs', ar: 'بيضتان')),
      Ingredient(LocalizedText(en: '150g dark chocolate, melted', ar: '150 غرام شوكولاتة داكنة مذابة')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Mix the dough ingredients and knead until smooth and elastic, then prove for 1 hour.',
        ar: 'اخلطي مكونات العجين واعجنيه حتى يصبح ناعمًا ومطاطيًا، ثم اتركيه يختمر ساعة كاملة.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Cut into rings, prove again for 30 minutes, then deep-fry until golden on both sides.',
        ar: 'قطّعي العجين إلى حلقات، اتركيها تختمر 30 دقيقة أخرى، ثم اقليها حتى تذهب من الجهتين.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Dip the cooled donuts into melted chocolate and finish with your favorite toppings.',
        ar: 'اغمسي الدونات بعد أن تبرد في الشوكولاتة المذابة وزينيها بما تحبين.',
      )),
    ],
  ),
  Recipe(
    id: 'strawberry_cake',
    title: const LocalizedText(en: 'Strawberry Cake', ar: 'كيك الفراولة'),
    shortDescription: const LocalizedText(
      en: 'Just bursting with fresh strawberries, this strawberry cake is one of the most refreshing bakes...',
      ar: 'مليء بالفراولة الطازجة، هذا الكيك من ألذّ وأكثر الحلويات انتعاشًا...',
    ),
    fullDescription: const LocalizedText(
      en: 'Just bursting with fresh strawberries, this strawberry cake is one of the most refreshing bakes of the '
          'season — soft vanilla sponge, strawberry buttercream, and a ring of glazed berries on top.',
      ar: 'مليء بالفراولة الطازجة، هذا الكيك من ألذّ وأكثر حلويات الموسم انتعاشًا — '
          'إسفنجية فانيليا طرية، وكريمة زبدة بالفراولة، وطبقة من التوت اللامع فوقه.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.red,
    hasCardColor: true,
    category: RecipeCategory.cake,
    prepMinutes: 50,
    servings: 8,
    ingredients: const [
      Ingredient(LocalizedText(en: '300g fresh strawberries', ar: '300 غرام فراولة طازجة')),
      Ingredient(LocalizedText(en: '250g self-raising flour', ar: '250 غرام دقيق ذاتي الانتفاخ')),
      Ingredient(LocalizedText(en: '200g caster sugar', ar: '200 غرام سكر ناعم')),
      Ingredient(LocalizedText(en: '3 large eggs', ar: '3 بيضات كبيرة')),
      Ingredient(LocalizedText(en: '200g unsalted butter', ar: '200 غرام زبدة غير مملحة')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Cream the butter and sugar until light and fluffy, then beat in the eggs one at a time.',
        ar: 'اخفقي الزبدة والسكر حتى يصبح الخليط خفيفًا وهشًا، ثم أضيفي البيض واحدة تلو الأخرى.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Fold in the flour and half of the chopped strawberries, then divide between two tins.',
        ar: 'أضيفي الدقيق ونصف كمية الفراولة المفرومة، ثم وزّعي الخليط على قالبين.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Bake at 180°C for 25 minutes, cool, then fill and top with buttercream and berries.',
        ar: 'اخبزي على حرارة 180° لمدة 25 دقيقة، دعيه يبرد، ثم احشيه وزيّنيه بالكريمة والتوت.',
      )),
    ],
  ),
  Recipe(
    id: 'fluffy_cake',
    title: const LocalizedText(en: 'Fluffy Cake', ar: 'الكيك الهش'),
    shortDescription: const LocalizedText(
      en: "This is a very good everyday cake devevered with baking powder. It's relatively light...",
      ar: 'كيك يومي رائع يعتمد على البيكنغ باودر، وهو خفيف نسبيًا...',
    ),
    fullDescription: const LocalizedText(
      en: "This is a very good everyday cake, leavened with baking powder. It's relatively light, with a soft "
          'crumb, and pairs beautifully with a simple dusting of icing sugar or a dollop of whipped cream.',
      ar: 'كيك يومي رائع يعتمد على البيكنغ باودر في انتفاخه. خفيف نسبيًا وطري القوام، '
          'ويُقدَّم بشكل رائع برشة بسيطة من سكر البودرة أو ملعقة من الكريمة المخفوقة.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.orange,
    hasCardColor: true,
    category: RecipeCategory.cake,
    prepMinutes: 45,
    servings: 8,
    ingredients: const [
      Ingredient(LocalizedText(en: '240g plain flour', ar: '240 غرام دقيق أبيض')),
      Ingredient(LocalizedText(en: '2 tsp baking powder', ar: 'ملعقتان صغيرتان بيكنغ باودر')),
      Ingredient(LocalizedText(en: '180g caster sugar', ar: '180 غرام سكر ناعم')),
      Ingredient(LocalizedText(en: '3 eggs', ar: '3 بيضات')),
      Ingredient(LocalizedText(en: '120ml whole milk', ar: '120 مل حليب كامل الدسم')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Sift the flour and baking powder together and set aside.',
        ar: 'انخلي الدقيق والبيكنغ باودر معًا وضعيهما جانبًا.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Beat the eggs and sugar until doubled in volume, then fold in the dry ingredients and milk.',
        ar: 'اخفقي البيض والسكر حتى يتضاعف الحجم، ثم أضيفي المكونات الجافة والحليب.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Pour into a lined tin and bake at 175°C for 30-35 minutes until springy to the touch.',
        ar: 'اسكبي الخليط في قالب مبطّن واخبزي على حرارة 175° لمدة 30-35 دقيقة حتى يرتد عند اللمس.',
      )),
    ],
  ),
  Recipe(
    id: 'lemon_cheesecake',
    title: const LocalizedText(en: 'Lemon Cheesecake', ar: 'تشيز كيك الليمون'),
    shortDescription: const LocalizedText(
      en: 'Tart Lemon Cheesecake sits atop an almond-graham cracker crust to add a delightful nuttiness...',
      ar: 'تشيز كيك ليمون حامض فوق قاعدة من بسكويت اللوز، تضيف نكهة مكسّرات لذيذة...',
    ),
    fullDescription: const LocalizedText(
      en: 'Tart Lemon Cheesecake sits atop an almond-graham cracker crust to add a delightful nuttiness to the '
          'traditional graham cracker crust. Finish the cheesecake with lemon curd for double the tart pucker!',
      ar: 'تشيز كيك ليمون حامض فوق قاعدة من بسكويت اللوز، تضيف نكهة مكسّرات لذيذة إلى القاعدة التقليدية. '
          'أنهي التشيز كيك بطبقة من كريمة الليمون لمضاعفة الحموضة اللذيذة!',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1524351199678-941a58a3df50?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.yellow,
    hasCardColor: true,
    category: RecipeCategory.cold,
    prepMinutes: 30,
    servings: 8,
    ingredients: const [
      Ingredient(LocalizedText(en: '110g digestive biscuits', ar: '110 غرام بسكويت دايجستيف')),
      Ingredient(LocalizedText(en: '50g butter', ar: '50 غرام زبدة')),
      Ingredient(LocalizedText(en: '25g light brown soft sugar', ar: '25 غرام سكر بني فاتح')),
      Ingredient(LocalizedText(en: '350g mascarpone', ar: '350 غرام جبنة ماسكاربوني')),
      Ingredient(LocalizedText(en: '75g caster sugar', ar: '75 غرام سكر ناعم')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Blitz the biscuits in a food processor. Melt the butter, take off heat and stir in the brown sugar and biscuit crumbs.',
        ar: 'اطحني البسكويت في المحضّرة. ذوّبي الزبدة، ارفعيها عن النار وأضيفي السكر البني وفتات البسكويت.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Line the base of a 20cm loose-bottomed cake tin with baking parchment. Press the biscuit into the bottom of the tin and chill.',
        ar: 'بطّني قاعدة قالب قطره 20 سم بورق زبدة. اضغطي خليط البسكويت في القاعدة وضعيه في الثلاجة.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Beat together the mascarpone, caster sugar, lemon zest and juice until smooth and creamy. Spread over the base and chill for a couple of hours.',
        ar: 'اخفقي الماسكاربوني والسكر وبرش وعصير الليمون حتى يصبح القوام ناعمًا. افرديه فوق القاعدة وبرّديه لساعتين.',
      )),
    ],
  ),
  Recipe(
    id: 'macaroons',
    title: const LocalizedText(en: 'Macaroons', ar: 'الماكرون'),
    shortDescription: const LocalizedText(
      en: 'Soft and chewy on the inside, crisp and golden on the outside - these are the...',
      ar: 'طرية ومطاطية من الداخل، مقرمشة وذهبية من الخارج - هذه هي...',
    ),
    fullDescription: const LocalizedText(
      en: 'Soft and chewy on the inside, crisp and golden on the outside — these coconut macaroons come together '
          'in one bowl and bake in under 20 minutes, no piping bag required.',
      ar: 'طرية ومطاطية من الداخل، مقرمشة وذهبية من الخارج — ماكرون جوز الهند هذا يُحضَّر في وعاء واحد '
          'ويُخبز في أقل من 20 دقيقة، دون الحاجة لكيس تزيين.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1569864358642-9d1684040f43?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.teal,
    hasCardColor: true,
    category: RecipeCategory.cake,
    prepMinutes: 25,
    servings: 12,
    ingredients: const [
      Ingredient(LocalizedText(en: '200g desiccated coconut', ar: '200 غرام جوز هند مبشور مجفف')),
      Ingredient(LocalizedText(en: '150g condensed milk', ar: '150 غرام حليب مكثف محلى')),
      Ingredient(LocalizedText(en: '2 egg whites', ar: 'بياض بيضتين')),
      Ingredient(LocalizedText(en: '1 tsp vanilla extract', ar: 'ملعقة صغيرة خلاصة فانيليا')),
      Ingredient(LocalizedText(en: 'Pinch of salt', ar: 'رشة ملح')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Whisk the egg whites with a pinch of salt until foamy, then fold in the coconut, condensed milk and vanilla.',
        ar: 'اخفقي بياض البيض مع رشة الملح حتى يصبح رغويًا، ثم أضيفي جوز الهند والحليب المكثف والفانيليا.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Scoop into mounds on a lined baking tray, spacing them well apart.',
        ar: 'شكّلي الخليط على شكل كومات فوق صينية مبطّنة، مع ترك مسافة كافية بينها.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Bake at 160°C for 15-18 minutes until golden at the tips, then cool completely on the tray.',
        ar: 'اخبزي على حرارة 160° لمدة 15-18 دقيقة حتى تذهب الأطراف، ثم اتركيها تبرد تمامًا في الصينية.',
      )),
    ],
  ),
  Recipe(
    id: 'cream_cupcakes',
    title: const LocalizedText(en: 'Cream Cupcakes', ar: 'كب كيك الكريمة'),
    shortDescription: const LocalizedText(
      en: 'Bake these easy vanilla cupcakes in just 35 minutes. Perfect for any occasion...',
      ar: 'اخبزي كب كيك الفانيليا السهل هذا خلال 35 دقيقة فقط. مثالي لأي مناسبة...',
    ),
    fullDescription: const LocalizedText(
      en: 'Bake these easy vanilla cupcakes in just 35 minutes, topped with billowy swirls of vanilla buttercream '
          'and a scattering of sugar flowers. Perfect for birthdays or an afternoon treat.',
      ar: 'اخبزي كب كيك الفانيليا السهل هذا خلال 35 دقيقة، وزيّنيه بدوامات من كريمة الزبدة بالفانيليا '
          'ورشة من زهور السكر. مثالي لأعياد الميلاد أو كحلوى بعد الظهر.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1614707267537-b85aaf00c4b7?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.pink,
    hasCardColor: true,
    category: RecipeCategory.cake,
    prepMinutes: 35,
    servings: 12,
    ingredients: const [
      Ingredient(LocalizedText(en: '150g self-raising flour', ar: '150 غرام دقيق ذاتي الانتفاخ')),
      Ingredient(LocalizedText(en: '150g caster sugar', ar: '150 غرام سكر ناعم')),
      Ingredient(LocalizedText(en: '150g unsalted butter', ar: '150 غرام زبدة غير مملحة')),
      Ingredient(LocalizedText(en: '3 eggs', ar: '3 بيضات')),
      Ingredient(LocalizedText(en: '1 tsp vanilla extract', ar: 'ملعقة صغيرة خلاصة فانيليا')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Cream the butter and sugar until pale, then beat in the eggs and vanilla.',
        ar: 'اخفقي الزبدة والسكر حتى يصبح اللون فاتحًا، ثم أضيفي البيض والفانيليا.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Fold in the flour and divide the batter between 12 cupcake cases.',
        ar: 'أضيفي الدقيق ووزّعي الخليط على 12 قالب كب كيك.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Bake at 180°C for 18-20 minutes, cool completely, then pipe with buttercream.',
        ar: 'اخبزي على حرارة 180° لمدة 18-20 دقيقة، اتركيها تبرد تمامًا، ثم زيّنيها بكريمة الزبدة.',
      )),
    ],
  ),
  Recipe(
    id: 'honey_cake',
    title: const LocalizedText(en: 'Honey Cake', ar: 'كيك العسل'),
    shortDescription: const LocalizedText(
      en: "The secret to this cake's fantastic flavor is the tiny amount of espresso from...",
      ar: 'سر النكهة الرائعة لهذا الكيك هو كمية صغيرة من الإسبريسو...',
    ),
    fullDescription: const LocalizedText(
      en: "The secret to this cake's fantastic flavor is the tiny amount of espresso brewed into the batter — "
          'it deepens the honey without adding any coffee taste, giving every layer a warm, caramelized finish.',
      ar: 'سر النكهة الرائعة لهذا الكيك هو كمية صغيرة من الإسبريسو المضافة إلى الخليط — '
          'تعمّق نكهة العسل دون أن تضيف طعم القهوة، فتمنح كل طبقة لمسة دافئة كأنها مكرملة.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1519869325930-281384150729?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.orange,
    hasCardColor: true,
    category: RecipeCategory.cake,
    prepMinutes: 50,
    servings: 8,
    ingredients: const [
      Ingredient(LocalizedText(en: '200g clear honey', ar: '200 غرام عسل صافٍ')),
      Ingredient(LocalizedText(en: '200g unsalted butter', ar: '200 غرام زبدة غير مملحة')),
      Ingredient(LocalizedText(en: '180g soft brown sugar', ar: '180 غرام سكر بني طري')),
      Ingredient(LocalizedText(en: '3 eggs', ar: '3 بيضات')),
      Ingredient(LocalizedText(en: '260g plain flour', ar: '260 غرام دقيق أبيض')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Warm the honey and butter together until melted, then let cool slightly.',
        ar: 'سخّني العسل والزبدة معًا حتى يذوبا، ثم اتركيهما يبردان قليلًا.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Whisk in the sugar and eggs, then fold in the flour until just combined.',
        ar: 'أضيفي السكر والبيض واخفقي، ثم أدخلي الدقيق حتى يتجانس الخليط.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Bake at 170°C for 40 minutes, then brush the warm cake with extra honey.',
        ar: 'اخبزي على حرارة 170° لمدة 40 دقيقة، ثم ادهني الكيك الدافئ بعسل إضافي.',
      )),
    ],
  ),
  Recipe(
    id: 'powdered_cake',
    title: const LocalizedText(en: 'Powdered Cake', ar: 'الكيك المبودر'),
    shortDescription: const LocalizedText(
      en: 'Heavy on the butter and nutmeg, this cake has all the flavors of your favorite...',
      ar: 'غني بالزبدة وجوزة الطيب، هذا الكيك يحمل كل نكهات حلواك المفضلة...',
    ),
    fullDescription: const LocalizedText(
      en: 'Heavy on the butter and nutmeg, this cake has all the flavors of your favorite coffee-shop treat, '
          'finished with a generous, snow-like dusting of powdered sugar right before serving.',
      ar: 'غني بالزبدة وجوزة الطيب، هذا الكيك يحمل كل نكهات حلوى المقهى المفضلة لديك، '
          'ويُنهى برشة سخية من سكر البودرة أشبه بالثلج قبل التقديم مباشرة.',
    ),
    imageUrl:
        'https://images.unsplash.com/photo-1533910534207-90f31029a78e?auto=format&fit=crop&w=400&q=60',
    color: RecipeColors.orange,
    hasCardColor: false,
    category: RecipeCategory.cake,
    prepMinutes: 55,
    servings: 8,
    ingredients: const [
      Ingredient(LocalizedText(en: '250g unsalted butter', ar: '250 غرام زبدة غير مملحة')),
      Ingredient(LocalizedText(en: '200g caster sugar', ar: '200 غرام سكر ناعم')),
      Ingredient(LocalizedText(en: '1 tsp ground nutmeg', ar: 'ملعقة صغيرة جوزة طيب مطحونة')),
      Ingredient(LocalizedText(en: '4 eggs', ar: '4 بيضات')),
      Ingredient(LocalizedText(en: '280g plain flour', ar: '280 غرام دقيق أبيض')),
    ],
    steps: const [
      RecipeStep(1, LocalizedText(
        en: 'Cream the butter, sugar and nutmeg until light and fluffy.',
        ar: 'اخفقي الزبدة والسكر وجوزة الطيب حتى يصبح الخليط خفيفًا وهشًا.',
      )),
      RecipeStep(2, LocalizedText(
        en: 'Beat in the eggs one at a time, then fold in the flour.',
        ar: 'أضيفي البيض واحدة تلو الأخرى، ثم أدخلي الدقيق.',
      )),
      RecipeStep(3, LocalizedText(
        en: 'Bake at 175°C for 45 minutes, cool, then dust generously with powdered sugar.',
        ar: 'اخبزي على حرارة 175° لمدة 45 دقيقة، دعيه يبرد، ثم رشّي فوقه سكر البودرة بسخاء.',
      )),
    ],
  ),
];
