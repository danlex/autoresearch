## Overview

Andrej Karpathy is an AI researcher, educator, and entrepreneur whose career tracks the arc of the deep learning era itself. He enrolled in the Stanford Computer Science PhD program in 2011 [1] and completed his dissertation, "Connecting Images and Natural Language," in 2016 under advisor Fei-Fei Li [64][65] — establishing hybrid CNN+RNN architectures for bidirectional vision-language alignment at a moment when computer vision and NLP were largely separate research communities. As one of OpenAI's founding research scientists (December 2015), he contributed deep reinforcement learning work and co-authored the "World of Bits" web-agent platform (ICML 2017) [1][7], before joining Tesla as Director of Artificial Intelligence and Autopilot Vision in June 2017 [19]. His five years at Tesla produced the vision-only neural network stack powering Autopilot and Full Self-Driving — a million-vehicle fleet that became the empirical foundation of the "Software 2.0" paradigm he articulated in a widely-read November 2017 essay [55][56]. After a second OpenAI stint (February 2023–February 2024) that included the influential "State of GPT" presentation at Microsoft Build [8][9], he founded Eureka Labs in July 2024 — what he called "the culmination of my passion in both AI and education over ~2 decades" [26].

Karpathy's intellectual output is unified by a single through-line: the observation that neural networks constitute not merely powerful tools but a qualitatively different way of writing programs. His 2017 "Software 2.0" essay argued that in domains like computer vision the dataset is the specification, training is compilation, and weights are the executable — drawing on Autopilot development as firsthand industrial evidence [55]. The essay influenced Stanford's Hazy Research group and, through them, Andrew Ng's data-centric AI movement [59][89]. Running alongside this paradigm work: a 2015 LSTM interpretability paper identified individual cells that learned to track syntactic structure through unsupervised training [68][82] — a methodological template whose intellectual heirs include Radford's Sentiment Neuron (2017) [83] and Anthropic's mechanistic interpretability program a decade later. In 2025, he extended the framing to "Software 3.0" at Y Combinator's AI Startup School: LLMs are "a new kind of computer" programmed in English, making software creation accessible to anyone who can describe what they want [63][95]. He introduced a distinctive psychological frame for LLMs — calling them "stochastic simulations of people" or "people spirits" whose capabilities are "jagged" in unintuitive ways and whose only persistent memory is the context window, producing a form of anterograde amnesia [63]. The practical expression arrived in February 2025 with "vibe coding" — fully prompt-driven development where the programmer "gives in to the vibes" and never reads the diff [93].

His educational output — cs231n (Stanford, 2015–2016), micrograd, nanoGPT (December 2022, 55,077 GitHub stars as of March 2026 [39]), and the Zero to Hero YouTube series — was built across his industry years as side projects, what Karpathy called "part-time, as side quests to my 'real job'" [26], all organized around three mutually reinforcing principles: first-principles construction, minimal and readable code, and intuition before formalism. Each artifact is governed by the Feynman imperative at the heart of his work: "What I cannot create, I do not understand" [29]. Eureka Labs (incorporated June 2024, announced July 16, 2024 [26][71]) is his first full-time commitment to that combination — its model is "Teacher + AI symbiosis," where a human expert designs curriculum and an AI teaching assistant scales delivery to every learner on demand [26][27]. The flagship course LLM101n, a 17-chapter progression from bigram models through transformers to RLHF and deployment, remains in development as of March 2026 [29]; nanochat (October 2025), covering the complete pretraining-through-RLHF pipeline on a single GPU node for approximately $48 [30], is the closest publicly shipped artifact.

---

## Career Timeline

| Date | Event |
|------|-------|
| 2011 | Enrolled in Stanford CS PhD program [1] |
| Sep 2014 | Human vs. ConvNet ImageNet experiment — 5.1% top-5 error vs. GoogLeNet's 6.8% [66] |
| Jan 2015 | Co-created and taught cs231n (first offering) with Fei-Fei Li [49] |
| Nov 2015 | Published "A Short Story on AI: A Cognitive Discontinuity" [31] |
| Dec 2015 | Joined OpenAI as founding Research Scientist [1] |
| 2016 | Completed Stanford PhD, "Connecting Images and Natural Language" [64][65] |
| Jun 2017 | Joined Tesla as Director of Artificial Intelligence and Autopilot Vision [19] |
| Nov 2017 | Published "Software 2.0" essay on Medium [55][56] |
| Apr 2019 | Tesla Autonomy Day — public disclosure of FSD chip and AI architecture [23] |
| Jun 2021 | CVPR 2021 keynote: vision-only Autopilot with 1M-vehicle data engine [69] |
| Aug 2021 | Tesla AI Day: HydraNet, temporal memory, transformer fusion [24] |
| Jul 13, 2022 | Departed Tesla after five years [10][11] |
| Dec 28, 2022 | Released nanoGPT on GitHub [39] |
| Feb 9, 2023 | Returned to OpenAI [2] |
| May 2023 | "State of GPT" at Microsoft Build 2023 [8][9] |
| Feb 13, 2024 | Left OpenAI (second time) [3] |
| Jul 16, 2024 | Founded Eureka Labs; announced LLM101n course [26][27][29] |
| Feb 2025 | Coined "vibe coding" [93] |
| Jun 18, 2025 | YC AI Startup School keynote: "Software Is Changing (Again)" — Software 3.0 [63][95] |
| Oct 2025 | Released nanochat; Dwarkesh Patel interview: "AGI is still a decade away" [30][17] |
| Jan 2026 | Coined "slopacolypse"; reversed public endorsement of Moltbook on security grounds [32][33] |

---

## Section Highlights

**[Intellectual Contributions](intellectual-contributions.md)**
Karpathy's PhD established CNN+RNN architectures for vision-language alignment [64]; Tesla Autopilot deployed them at fleet scale through a 1.5-petabyte iterative data engine with 221 targeted collection triggers [70]; and Software 2.0 (2017) and Software 3.0 (2025) framed the two paradigm shifts underlying both [55][63]. A 2015 LSTM interpretability paper identified individual cells tracking syntactic structure through unsupervised training [68][82] — a methodological ancestor of Radford's Sentiment Neuron [83] and Anthropic's superposition and monosemanticity research [84][85], though the debt is intellectual rather than explicitly cited.

**[Education and Teaching](education-and-teaching.md)**
cs231n (Winter 2015, Stanford) and nanoGPT (December 2022, 55,077 GitHub stars as of March 2026) are the most fully documented artifacts [49][39]. All of Karpathy's educational work shares three principles — build each component from scratch, keep the code minimal and readable, sequence intuition before formalism — under the Feynman governing imperative: "What I cannot create, I do not understand" [29]. A community speedrun competition catalyzed by nanoGPT reduced GPT-2 training time from ~45 minutes to under 3 minutes in one year and was formally benchmarked in a June 2025 academic paper [47].

**[Views on AI Future](views-on-ai-future.md)**
Karpathy is a pragmatic safety-aware builder — neither a doomer nor an accelerationist — who estimated AGI "at least a decade away" in October 2025, calling ten years "a very bullish" prediction and positioning himself as roughly "5–10x pessimistic" relative to Silicon Valley consensus [17][38][35]. His 2015 short story dramatized interpretability gaps and shutdown failures the month before he co-founded OpenAI [31]; his 2026 "slopacolypse" warning targeted quality degradation across GitHub, arXiv, and social media [32]; and he reversed his public endorsement of the Moltbook agent network on security grounds after testing it in an isolated environment [33].

**[Eureka Labs](eureka-labs.md)**
Founded July 16, 2024 as an AI-native school organized around "Teacher + AI symbiosis": a human expert designs curriculum, an AI teaching assistant scales delivery [26][27]. The long-horizon vision is "Starfleet Academy" — human faculty concentrated on curriculum design while AI handles routine instruction [17]. Course materials are designed for "eurekas per second" and structured around "pain before solution": each component introduced as the fix for a problem the student has already felt [17]. LLM101n remains unshipped as of March 2026 [29]; nanochat (October 2025) covers the complete pretraining-through-RLHF pipeline on a single GPU node for approximately $48 [30].

**[Key Relationships and Collaborations](key-relationships-and-collaborations.md)**
Justin Johnson co-instructed cs231n, co-authored two papers including DenseCap (CVPR 2016 Oral), and carried the course architecture to the University of Michigan after Karpathy left for Tesla [50][74]. Percy Liang shaped Karpathy's "research philosophy" — his words in the dissertation acknowledgments [64] — and proved to be the only committee member to maintain an active research collaboration with Karpathy after the PhD, co-authoring World of Bits (ICML 2017) across the OpenAI–Stanford boundary [7].

---

## Sections

- [Intellectual Contributions](intellectual-contributions.md)
- [Education and Teaching](education-and-teaching.md)
- [Views on AI Future](views-on-ai-future.md)
- [Eureka Labs](eureka-labs.md)
- [Key Relationships and Collaborations](key-relationships-and-collaborations.md)
- [Sources](sources.md)
- [Open Questions](open-questions.md)
