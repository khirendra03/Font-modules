| Property | Value |
|---|---|
| Title | Recursive |
| Designers | Arrow Type, Lisa Huang, Katja Schimmel, Rafał Buchner |
| Home URL | https://www.recursive.design/ |
| Source | https://github.com/arrowtype/recursive |
| License | [SIL OPEN FONT LICENSE](https://github.com/arrowtype/recursive/blob/main/OFL.txt) |
| Ligatures | True |
| Italics | True |
| Variable | True |
| Stylesheet URL | recursive/stylesheet.css |

## Variable Axes

Recursive has the following axes:

| Axis       | Tag    | Range        | Default | Description                                                     |
| ---------- | ------ | ------------ | ------- | --------------------------------------------------------------- |
| Monospace  | `MONO` | 0 to 1       | 0       | Sans (natural-width) to Mono (fixed-width)                      |
| Casual     | `CASL` | 0 to 1       | 0       | Linear to Casual                                                |
| Weight     | `wght` | 300 to 1000  | 300     | Light to ExtraBlack. Can be defined with usual font-weight property. |
| Slant      | `slnt` | 0 to -15     | 0       | Upright (0°) to Slanted (about 15°)                             |
| Cursive    | `CRSV` | 0, 0.5, or 1 | 0.5     | Always roman (0), auto (0.5), or always cursive (1)             |

### Axis Definitions
<details>

  - **Monospace** `MONO` - 0 to 1. Adjusts the glyph widths from proportional or “Sans” (0) to fixed-width or “Mono” (1).

    *Recommended use:* In general, the proportional design is more readable in text and UI, while the monospace design is more appropriate for code and text in which letter disambiguation is especially critical (e.g. passwords, ID numbers, tabular data, etc).

  - **Casual** `CASL` - 0 to 1. Adjusts the expressive style or “genre” of the glyphs. In Recursive, this goes from from Linear (0) to Casual (1). 

    *Recommended use:* The Linear style shares a similar structure to fonts classified as *lineal*, merging aspects of humanist sans with rationalized, compact, flat-sided letterforms. This regular, familiar structure makes it appropriate for long-form text requiring focus (e.g. paragraphs, full code documents, and punchy headlines). The Casual style is inspired by single-stroke casual signpainting, but drawn for small sizes. It is most useful in shorter-form text where a warm and inviting tone is desired (e.g. blog post headlines, store signage, and computer terminals).

  - **Weight** `wght` - 300 to 1000. The overall thickness of letters and the darkness of text composed with them. Notably, in Recursive, the weight axis does not affect glyph width. A bold weight takes the same amount of space as a light weight, even at in proportional styles of the `MONO` axis.

    *Recommended use:* Differences in weight can provide emphasis in text, show user interaction, or adjust the tone of communication. For light text on dark backgrounds, 400 (“Regular”) tends to be appropriate for text and code. For dark text on a light background, it can be beneficial to adjust the weight upwards to 500 (“Medium”).
    
    *Why isn’t it a Grade axis?* See [Issue #365](https://github.com/arrowtype/recursive/issues/365)

  - **Slant** `slnt` – 0 to -15. The "forward lean" of letters. Note: `-15` (negative 15) corresponds to a 15° clockwise slant, due to type design's roots in geometry. If the Italic axis is at its default value, going past a slant of `-13.99` will activate "cursive" letters, converting them to more-handwritten forms such as the simplified, "single story" `a` and `g`.

    *Recommended use:* Use Slant as a secondary way to emphasize text or vary typographic tone. In text, it can be useful to use a partial slant of around -9, while at display sizes, you can expect the most precise outlines at either 0 or -15. You can also animate from `0` to `-13` without letterforms or glyph widths changing, which is great for things like hovered links or buttons.

  - **Cursive** `CRSV` – 0, 0.5, or 1. Controls the substitution of cursive forms along the Slant axis. "Off" (0) maintains Roman letterforms such as a "double story" `a` and `g`, "Auto" (0.5) allows for Cursive substitution, and "On" (1) asserts cursive forms even in upright text with a Slant of 0.

    *Recommended use:* Use Cursive as a tertiary way to emphasize text, or as

 a way to have more control over animated text (e.g. a hyperlink that slants upon user interaction can by styled with Cursive 0 or 1 to prevent the abrupt changes of glyph substitution).
</details>
  
### Advanced design recommendations
<details>
  
  In general, Recursive is intended for small-to-medium sized usage, particularly on screen. However, it is useful to understand which stylistic ranges work best in what contexts. A few guidelines worth knowing:

  | Style range                  | Recommended size                 | Recommended use case                                |
  | ---------------------------- | -------------------------------- | --------------------------------------------------- |
  | Casual 0 *(Linear)*, Weight 300–800 *(Light–ExtraBold)*  | 8px to 72px   | General use (especially for longer text)   |
  | Casual 1 *(Casual)*, Weight 300–800 *(Light–ExtraBold)*  | 14px to 72px  | General use (more personality)             |
  | Weights 801–900 *(Black–ExtraBlack)*      | 32px to 144px | Headlines, display typography              |
  | Intermediate values of Casual and Slant  | 10px to 40px  | Good in text, but may not look as good in display sizes |


  Things to be aware of:
  - If you use weights 300–800 for large text, it may look good to slightly reduce letter-spacing (also called _tracking_).
  - The heaviest weights of Recursive are _really heavy_, so they need to be a little larger to remain legible.
  - Casual and Slant axes look great with intermediate values at text sizes, but they are mostly intended to be used at either fully "on or off" values, with intermediates available to allow animated stylistic transitions. If you are setting type at large sizes, avoid intermediate `CASL` and `slnt` values. If you stick to named instances in design apps (e.g. `Mono Casual Bold Italic`, etc), this is handled for you automatically.
  - The Casual Italic instances are drawn to work well in text but are also the most expressive styles of the family – try them at large sizes to show off their wavy stems and really make a statement! 🏄‍♂️🏄‍♀️
</details>

## OpenType Features

Recursive is built with a number of OpenType features that make it simple to control a few handy typographic features.

![OpenType Features in Recursive](https://github.com/khirendra03/Font-modules/blob/main/Modules/Recursive/recursive-v1.064-opentype_features.png)

<head>
  <link rel="stylesheet" href="styles.css">
</head>

### Language Support
<details>
  <summary>Languages</summary>

Recursive is designed with a modified Google Fonts Latin Expert character set, including numerous useful symbols for currencies & math (see the [Character Set notes](https://github.com/arrowtype/recursive/tree/main/docs/00--character_set_for_google_fonts) for more details), plus support for the following languages:

```
Abenaki, Afaan Oromo, Afar, Afrikaans, Albanian, Alsatian, Amis, Anuta, Aragonese, Aranese, Aromanian, Arrernte, Arvanitic (Latin), Asturian, Atayal, Aymara, Azerbaijani, Bashkir (Latin), Basque, Belarusian (Latin), Bemba, Bikol, Bislama, Bosnian, Breton, Cape Verdean Creole, Catalan, Cebuano, Chamorro, Chavacano, Chichewa, Chickasaw, Cimbrian, Cofán, Cornish, Corsican, Creek, Crimean Tatar (Latin), Croatian, Czech, Danish, Dawan, Delaware, Dholuo, Drehu, Dutch, English, Esperanto, Estonian, Faroese, Fijian, Filipino, Finnish, Folkspraak, French, Frisian, Friulian, Gagauz (Latin), Galician, Ganda, Genoese, German, Gikuyu, Gooniyandi, Greenlandic (Kalaallisut), Guadeloupean Creole, Gwich’in, Haitian Creole, Hän, Hawaiian, Hiligaynon, Hopi, Hotcąk (Latin), Hungarian, Icelandic, Ido, Igbo, Ilocano, Indonesian, Interglossa, Interlingua, Irish, Istro-Romanian, Italian, Jamaican, Javanese (Latin), Jèrriais, Kaingang, Kala Lagaw Ya, Kapampangan (Latin), Kaqchikel, Karakalpak (Latin), Karelian (Latin), Kashubian, Kikongo, Kinyarwanda, Kiribati, Kirundi, Klingon, Kurdish (Latin), Ladin, Latin, Latino sine Flexione, Latvian, Lithuanian, Lojban, Lombard, Low Saxon, Luxembourgish, Maasai, Makhuwa, Malay, Maltese, Manx, Māori, Marquesan, Megleno-Romanian, Meriam Mir, Mirandese, Mohawk, Moldovan, Montagnais, Montenegrin, Murrinh-Patha, Nagamese Creole, Nahuatl, Ndebele, Neapolitan, Ngiyambaa, Niuean, Noongar, Norwegian, Novial, Occidental, Occitan, Old Icelandic, Old Norse, Onĕipŏt, Oshiwambo, Ossetian (Latin), Palauan, Papiamento, Piedmontese, Polish, Portuguese, Potawatomi, Q’eqchi’, Quechua, Rarotongan, Romanian, Romansh, Rotokas, Sami (Inari Sami), Sami (Lule Sami), Sami (Northern Sami), Sami (Southern Sami), Samoan, Sango, Saramaccan, Sardinian, Scottish Gaelic, Serbian (Latin), Seri, Seychellois Creole, Shawnee, Shona, Sicilian, Silesian, Slovak, Slovenian, Slovio (Latin), Somali, Sorbian (Lower Sorbian), Sorbian (Upper Sorbian), Sotho (Northern), Sotho (Southern), Spanish, Sranan, Sundanese (Latin), Swahili, Swazi, Swedish, Tagalog, Tahitian, Tetum, Tok Pisin, Tokelauan, Tongan, Tshiluba, Tsonga, Tswana, Tumbuka, Turkish, Turkmen (Latin), Tuvaluan, Tzotzil, Uzbek (Latin), Venetian, Vepsian, Vietnamese, Volapük, Võro, Wallisian, Walloon, Waray-Waray, Warlpiri, Wayuu, Welsh, Wik-Mungkan, Wiradjuri, Wolof, Xavante, Xhosa, Yapese, Yindjibarndi, Zapotec, Zarma, Zazaki, Zulu, Zuni
```
</details>

### Changelog
<details>

 ### 20210811
 - initial build
 
 ### 20211103
 - switched to OMF template
 - adopted to support Android 12
 
 ### 20230530
 - Optimized metrics
 - adopted to support Android 13
 - adopted to support magisk 26.1
 - added OTL feature
 - added in module updator
 - added info+changelog file
 - backup module at sourceforge
 - module version is now based on font release version and date.
 
</details>
