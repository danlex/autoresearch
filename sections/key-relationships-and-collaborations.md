## Key Relationships and Collaborations

### Justin Johnson

Justin Johnson is the most structurally significant collaborator in Karpathy's Stanford period. Their relationship operated across three independent domains simultaneously: shared doctoral supervision under Fei-Fei Li, co-teaching on cs231n, and joint first-authorship on research papers — a density of collaboration uncommon even among PhD cohort peers.

**Background and shared context.** Johnson was a PhD student at Stanford's Vision Lab from 2012 to 2018, advised by Fei-Fei Li — the same lab and the same advisor as Karpathy [75]. The overlap placed both researchers in close proximity during the peak years of deep learning's breakout in computer vision (2014–2016).

**Confidence: HIGH | Depth: HIGH**

---

#### cs231n: From TA to Co-Instructor

When Karpathy launched cs231n in Winter 2015 as an entirely new course, Johnson served as a Teaching Assistant, holding office hours and handling student support [49][51]. The following year, for Winter 2016, Johnson was elevated to full co-instructor alongside Karpathy and Fei-Fei Li, with the official course page crediting him specifically for the assignments while Karpathy contributed the class notes and lectures [50]. The division was deliberate: Karpathy's lecture-notes-first approach (carried over from the "Hacker's Guide to Neural Networks" [53]) produced the conceptual scaffolding, while Johnson built the hands-on problem sets that students worked through to internalize the material.

When Karpathy left Stanford for Tesla in mid-2017 and did not return to teach cs231n, Johnson stayed on as an instructor for the Spring 2017 offering alongside Fei-Fei Li and Serena Yeung [54]. He subsequently adapted cs231n's structure into EECS 498/598 at the University of Michigan, where he brought the same pedagogical framework to a new institution — a direct continuation of the course architecture he and Karpathy had built together.

**Confidence: HIGH | Depth: HIGH**

---

#### Research Collaboration: Two Co-Authored Papers

The academic record shows two joint papers with clear shared contribution during Karpathy's final PhD years:

**"Visualizing and Understanding Recurrent Networks" (arXiv June 2015; ICLR 2016 Workshop).** Authored by Karpathy, Johnson, and Li, the paper analyzed character-level LSTM language models to identify interpretable internal structure: specific cells that tracked position within quotation marks, line lengths, and code indentation depth [68]. The work was notable for treating neural networks as objects of scientific inquiry rather than engineering tools — probing what the networks had actually learned rather than only measuring their outputs.

**"DenseCap: Fully Convolutional Localization Networks for Dense Captioning" (CVPR 2016 Oral).** Authored by Johnson, Karpathy, and Li, with Johnson and Karpathy credited as equal contributors [74]. DenseCap introduced the dense captioning task: simultaneously localizing all salient regions in an image and generating a natural-language description for each. The architecture — a Fully Convolutional Localization Network (FCLN) capable of processing an image end-to-end in a single forward pass — was accepted as an oral presentation at CVPR 2016, a strong indicator of impact within the computer vision community [74].

The two papers span different technical areas (sequence models for language and vision-language alignment respectively), underscoring that the collaboration was not narrowly focused but followed Karpathy's broader interest in connecting visual and linguistic representations — the through-line of his 2016 PhD dissertation [64].

**Confidence: HIGH | Depth: HIGH**

---

#### Subsequent Trajectory

After completing his PhD in 2018, Johnson joined Facebook AI Research (FAIR) as a Research Scientist before becoming an Assistant Professor at the University of Michigan in 2019 [75]. He co-founded World Labs in 2024, a spatial intelligence startup [76]. His career arc — from PhD student TA to course co-instructor to independent researcher and eventually company founder — closely parallels Karpathy's own pattern of moving from academic research to applied AI entrepreneurship.

**Confidence: MEDIUM | Depth: MEDIUM**

**Uncertainty:** Johnson's exact PhD completion year (confirmed as 2018 by career timeline but not directly sourced from a dissertation record). The task description referenced "Princeton" as a post-Stanford destination; this is incorrect — Johnson's faculty position was at the University of Michigan, confirmed by his institutional page [75].

---

### Percy Liang

Percy Liang holds a structurally unique position in the Karpathy relationship network: he is the only person documented as both a formal academic mentor during the PhD and a research collaborator after it. The relationship originated at Stanford, persisted into the OpenAI period, and shaped what Karpathy himself identified as his core "research philosophy."

**Background.** Liang is an Associate Professor of Computer Science at Stanford University (BS MIT 2004, PhD UC Berkeley 2011) and Director of the Center for Research on Foundation Models (CRFM) [88]. His research spans NLP, machine learning, grounding, and reasoning — areas that overlap directly with Karpathy's dissertation work connecting visual and linguistic representations. That topical overlap explains his committee appointment: Karpathy's dissertation, focused on vision-language alignment, sat at the intersection of computer vision (Fei-Fei Li's domain) and natural language processing (Manning and Liang's domain).

**Confidence: HIGH | Depth: HIGH**

---

#### Role on Karpathy's PhD Committee (2016)

Liang served as one of two non-primary dissertation readers on Karpathy's 2016 Stanford dissertation "Connecting Images and Natural Language," alongside Christopher Manning; Fei-Fei Li was the primary adviser [64][65]. His formal certification appears on the dissertation signature page [64].

The acknowledgments section of the dissertation gives the relationship unusual weight. Karpathy named both committee members explicitly: first Manning — described as "a seemingly infinite generative model of unique perspectives and insightful comments, feedback and advice" — and immediately after, Liang: "My thinking and research philosophy has similarly been shaped by thoughtful discussions and interactions with Percy Liang" [64]. The phrasing — "research philosophy" rather than "feedback on the thesis" — indicates that Liang's influence was conceptual and methodological, not narrowly about the dissertation's technical content.

**Note on quotes:** Both quotations are attributed to the acknowledgments section of [64] (the dissertation PDF). The source record for [64] confirms advisors and abstract but does not independently verify that the acknowledgments text was extracted from the PDF. These quotes should be treated as approximate/paraphrased until directly verified against the dissertation.

**Confidence: HIGH | Depth: HIGH**

---

#### World of Bits: A Post-PhD Collaboration (ICML 2017)

When Karpathy joined OpenAI as a founding research scientist in late 2015 and began working on agents that interact with the web, Liang remained the natural academic bridge. The "World of Bits: An Open-Domain Platform for Web-Based Agents" paper (ICML 2017) carries five authors: Tianlin (Tim) Shi (Stanford/OpenAI), Andrej Karpathy (OpenAI), Linxi (Jim) Fan (Stanford), Jonathan Hernandez (OpenAI), and Percy Liang (Stanford) [7]. The author affiliations mark it explicitly as a joint OpenAI–Stanford project, with Liang as the Stanford PI (last-author position in the CS convention) and Karpathy as the second author representing OpenAI's contribution [7]. The paper itself states: "This work was done in collaboration between OpenAI and Stanford" [7].

The World of Bits work arrived roughly one year after Karpathy defended his dissertation. The platform proposed in the paper — a browser-based environment where reinforcement learning agents could take actions on real websites using keyboard and mouse — extended Karpathy's interest in grounding representations in interactive environments, a thread running through his dissertation's vision-language alignment work. Liang's NLP expertise, particularly in grounding and semantics, was relevant to the web-agent framing, which required parsing natural-language task descriptions alongside visual observations.

**Confidence: HIGH | Depth: HIGH**

---

#### Scope of the Relationship and Limits of the Record

No documentation of further Liang–Karpathy co-authorship has been found after the 2017 ICML paper. Liang does not mention Karpathy on his Stanford faculty page [88], and Karpathy's public communications after departing for Tesla in mid-2017 do not reference Liang. The relationship is bounded: active from approximately 2014 (when committee service would have begun) through 2017, and thereafter undocumented.

What distinguishes Liang from other committee members is the direction of the bridge: Christopher Manning (also on the committee) was a senior Stanford NLP professor with no documented post-PhD collaborations with Karpathy; Fei-Fei Li was the primary PhD supervisor but is not a co-author on World of Bits. Liang is the one committee member who moved with Karpathy from Stanford into the OpenAI-era research agenda, suggesting that the intellectual affinity Karpathy described in his acknowledgments translated into an active cross-institutional collaboration when an appropriate project materialized.

**Confidence: MEDIUM | Depth: MEDIUM**

**Uncertainty:** It is not established whether Liang initiated the World of Bits collaboration (pulling in Karpathy's OpenAI involvement) or whether Karpathy initiated it (bringing in Liang as the Stanford PI). The paper's correspondence contact is the Stanford student (Shi), suggesting the project may have originated in Liang's lab. No primary source directly addresses the origin of the collaboration.

---
