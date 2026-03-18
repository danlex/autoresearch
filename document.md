# Andrej Karpathy — Research Document
Coverage: 65% | Tasks: 2/2 | Sources: 54 | Last updated: 2026-03-18

## Intellectual Contributions

### Role at OpenAI

**Confidence: MEDIUM | Depth: HIGH**

> **Review note:** Confidence remains MEDIUM. Key dates rely on Tier 2/3 press sources only (June 2017 Tesla start), the Feb 13 vs Feb 14 2024 departure date conflict is unresolved, and the rationale for the 2017 OpenAI→Tesla transition has no Tier 1 primary source. Eureka Labs date conflict resolved — July 2024 confirmed by [26][27]. Depth remains HIGH — coverage within what is documented is thorough.

Andrej Karpathy was one of OpenAI's founding members, joining in December 2015 as a Research Scientist alongside Sam Altman, Elon Musk, Ilya Sutskever, Greg Brockman, and others. His first stint (2015–2017) focused on deep learning applied to computer vision, generative modeling, and reinforcement learning.

Among his notable projects at OpenAI was **World of Bits** (2016–2017), a platform for training web-based agents that controlled software environments through simulated keyboard and mouse input. The resulting paper, "World of Bits: An Open-Domain Platform for Web-Based Agents" (ICML 2017), was co-authored with Tianlin Shi, Linxi Fan, Jonathan Hernandez, and Percy Liang. He also contributed to **OpenAI Universe**, the broader platform enabling AI agents to interact with software via visual interfaces. On his personal blog he published "Deep Reinforcement Learning: Pong from Pixels" (May 2016), applying policy gradient methods to Atari environments using OpenAI Gym.

Karpathy left OpenAI in June 2017 to become Tesla's Director of Artificial Intelligence and Autopilot Vision, reporting directly to Elon Musk. No primary statement from Karpathy has surfaced explaining that specific transition; the "Musk recruited him" framing is press-derived (Tier 2/3).

After leaving Tesla in July 2022, Karpathy announced his return to OpenAI on February 9, 2023, stating: "I am very inspired by the impact of their work and I have personally benefited greatly from it. The future potential is especially exciting." His second stint centered on building a new team focused on **midtraining and synthetic data generation**. He also delivered the widely-shared public talk **"State of GPT"** at Microsoft Build 2023 (May 23, 2023), covering the full GPT training pipeline — pretraining, supervised fine-tuning, reward modeling, and RLHF — and offering practical guidance on prompting, retrieval-augmented generation, and agent design. The slide deck is hosted directly on his personal site (karpathy.ai/stateofgpt.pdf), making it a Tier 1 primary record of his thinking.

He left OpenAI a second time on February 13, 2024. In his own words: "nothing 'happened' and it's not a result of any particular event, issue or drama... Actually, being at OpenAI over the last ~year has been really great — the team is really strong, the people are wonderful, and the roadmap is very exciting. My immediate plan is to work on my personal projects and see what happens." He cited a desire to pursue personal projects, and subsequently announced Eureka Labs in July 2024. In a 2025 interview with Dwarkesh Patel, he reflected critically on OpenAI's early RL-on-games approach as "a misstep that even the early OpenAI that I was a part of adopted," while also describing the original AGI definition as "a system you could go to that can do any economically valuable task at human performance or better."

**Uncertainty:**
- Why Karpathy left OpenAI in 2017 to join Tesla has no primary source explanation. The "June 2017" departure month is sourced from press only (Tier 2/3); no Tier 1 primary source confirms the exact month.
- **Date conflict (Feb 13 vs 14 2024):** The body text states "February 13, 2024" for his second departure, but the source label in the Sources section reads "Feb 14 2024". Cannot resolve without revisiting the primary tweet.
- **Eureka Labs date conflict:** ~~RESOLVED~~ July 2024 confirmed by Tier 1 sources [26][27]. See Eureka Labs section.
- His specific individual contributions to particular model releases during his second stint are not publicly attributed.

## Education and Teaching

**Confidence: MEDIUM | Depth: MEDIUM**

> **Review note:** nanoGPT and cs231n are now fully sourced with Tier 1 primary sources — see their dedicated subsections below. The broader pedagogical principles section draws on those sources but micrograd and the Zero to Hero series remain without independent primary-source citations. Confidence remains MEDIUM; the section ceiling is HIGH once micrograd and Zero to Hero receive equivalent treatment. The already-cited Lex Fridman Podcast #333 [18] and Dwarkesh Patel 2025 interview [17] remain natural candidates for first-person pedagogical-philosophy statements and have not yet been mined for this section.

Karpathy's educational output spans four major public artifacts: **cs231n** (Stanford's Convolutional Neural Networks for Visual Recognition course, which he co-created and taught), **micrograd** (a minimalist autograd engine implemented in roughly 150 lines of pure Python), **nanoGPT** (a minimal, readable GPT-2 implementation created December 2022 [39]), and the **Zero to Hero** YouTube series (a video lecture series on building neural networks from scratch). The consistency across these four formats — lecture course, open-source library, reference implementation, video series — is itself diagnostic: all four are organized around the same three mutually reinforcing pedagogical principles.

**1. First-principles construction.** Rather than introducing deep learning as a stack of APIs to be consumed, Karpathy builds every component from scratch, starting from the mathematical operations that underlie it. In micrograd, backpropagation is implemented by hand before any higher-level abstraction is introduced. In Zero to Hero, the series begins with a character-level language model built purely from tensor operations before arriving at the transformer architecture. The pedagogical wager is that a learner who has constructed the mechanism understands it in a qualitatively different and more durable way than one who learned only to call it.

**2. Minimal, readable code.** Construction only teaches if the code remains legible throughout. Karpathy's educational repositories treat readability as a design constraint, not a concession to beginners. nanoGPT is explicitly designed to be the simplest, fastest implementation of a medium-sized GPT — every abstraction that exists for production-engineering reasons is stripped out [39]. The result is that the code itself becomes the explanation: each line earns its place, and the architecture becomes inspectable without cross-referencing documentation. This stands in deliberate contrast to both industry codebases and academic reference implementations, which typically accumulate complexity that obscures the underlying logic.

**3. Intuition before formalism.** The first two principles determine *what* gets built and *how* it is written; this third governs *when* abstraction is introduced. Concrete worked examples and visual intuitions precede mathematical formalization, not the reverse. cs231n was recognized for its intuition-first treatment of topics including backpropagation and convolutional architectures. This sequencing — concrete to abstract rather than abstract to concrete — inverts the standard academic presentation and substantially lowers the prerequisite barrier for learners without strong mathematical backgrounds.

**Contrast with conventional AI education:** These three principles, taken together, constitute a structural inversion of standard deep learning pedagogy. Conventional curricula, whether academic or MOOC-format, typically proceed top-down: introduce the framework, define the problem class, demonstrate the API, interpret results. Karpathy's approach inverts this sequence at every level — construction before consumption, legibility before scale, intuition before formalism. The activation energy required is higher at the outset, but the resulting mental model is more robust: a learner who has built micrograd from scratch, written a character-level language model in raw tensor operations, and then read nanoGPT is far less likely to attribute model behavior to opaque framework internals than one who began with a high-level API tutorial.

### nanoGPT: Creation, Design, and Reception

**Confidence: HIGH | Depth: HIGH**

nanoGPT was created by Karpathy and first committed to GitHub on **December 28, 2022** [39]. Its purpose, as stated in the README, is "the simplest, fastest repository for training/finetuning medium-sized GPTs" [39]. The repository spread before Karpathy had even announced it publicly: it appeared on Hacker News on January 11, 2023 and was trending before he tweeted about it. His announcement tweet confirmed the organic spread: "Didn't tweet nanoGPT yet (quietly getting it to good shape) but it's trending on HN so here it is :)" [40].

**Design principles.** The README explicitly frames nanoGPT as "a rewrite of minGPT that prioritizes teeth over education" [39] — a deliberate turn from its explicitly educational predecessor (minGPT) toward a practical, performance-validated implementation that still maintains radical simplicity. Two core files contain all essential logic: `train.py` (~300 lines) and `model.py` (~300 lines). Karpathy's description of its accessibility is direct: "Because the code is so simple, it is very easy to hack to your needs, train new models from scratch, or finetune pretrained checkpoints." [39] The performance target was concrete: reproduction of GPT-2 (124M parameters) to published benchmark quality on a single 8-GPU A100 node [39][40] — providing researchers a verified baseline rather than an untested reference.

**Companion lectures.** On January 17, 2023, Karpathy released a companion YouTube lecture, **"Let's build GPT: from scratch, in code, spelled out"** (1 hour 56 minutes), which narrates the construction of nanoGPT line by line [41][42]. He described it as building "a Transformer following the 'Attention Is All You Need' paper in the language modeling setting" ending with "the core of nanoGPT" [42]. In June 2024 he published a follow-up, **"Let's reproduce GPT-2 (124M)"** (~4 hours), with companion repository `build-nanogpt`, walking through the complete reproduction pipeline from an empty file [43].

**Adoption evidence.** As of March 2026, nanoGPT has accumulated **55,077 GitHub stars** and **9,377 forks** [39]. A GitHub issue opened April 2024 documented the scale of academic uptake: the project "is being used a lot in academia/research, especially as a way to explain and showcase LLMs and the decoder-only Transformer architecture" [45]. Academic papers citing nanoGPT include work at the AAAI Workshop on Privacy-Preserving AI (2024) [46] and a June 2025 paper, "The Automated LLM Speedrunning Benchmark: Reproducing NanoGPT Improvements," which formalized a community speedrun competition — reducing GPT-2 training time from ~45 minutes (June 2024) to under 3 minutes (May 2025) — as a formal AI research benchmark [47]. The speedrun, which Karpathy endorsed in October 2024 [48], also catalyzed development of the Muon optimizer, subsequently applied to larger-scale LLM training [47].

**Retrospective and deprecation.** In a 2025 tweet, Karpathy described nanoGPT's arc: "First I wrote it as a small little repo to teach people the basics of training GPTs. Then it became a target and baseline for my port to direct C/CUDA." [44] In November 2025, the README was updated with a deprecation notice — "nanoGPT (this repo) is now very old and deprecated but I will leave it up for posterity" [39][44] — directing users toward nanochat, the broader pipeline project covering pretraining through RLHF and chat interface capabilities that nanoGPT's pretraining-only scope did not include.

**Why it became a reference implementation.** Three properties coexisted in nanoGPT that rarely appear together: (1) radical simplicity (two ~300-line files, no unnecessary abstractions), (2) verified performance against a known benchmark (GPT-2 at 124M parameters, reproducible on standard hardware), and (3) a companion lecture narrating the construction in full. Most open-source implementations trade simplicity for coverage; most educational implementations trade performance for legibility. nanoGPT refused both tradeoffs. A researcher or student could read the entire codebase in an afternoon, run it on accessible hardware, and trust the results against a published benchmark — qualities that made it the natural starting point for both teaching and research modification [39][40][41][47].

### cs231n: Convolutional Neural Networks for Visual Recognition

**Confidence: HIGH | Depth: HIGH**

cs231n was first offered in **Winter 2015** at Stanford University as an entirely new class. The Stanford course website FAQ for the 2015 offering explicitly states: "Yes, this is an entirely new class designed to introduce students to deep learning in context of Computer Vision" [49]. The course GitHub notes repository (cs231n/cs231n.github.io) was created on **January 5, 2015**, coinciding with the first lecture [52].

**Instructors and teaching tenure.** The 2015 offering was taught by **Fei-Fei Li** and **Andrej Karpathy**, with teaching assistants Justin Johnson, Yuke Zhu, Brett Kuprel, and Ben Poole [49]. In the 2016 offering (Winter 2015/2016), the division of labor became explicit: Karpathy was credited for class notes and lectures, Justin Johnson for assignments, and Fei-Fei Li for course administration [50]. Karpathy's teaching tenure spans exactly two offerings: Winter 2015 and Winter 2016. He is absent from the Spring 2017 instructors listing — Fei-Fei Li, Justin Johnson, and Serena Yeung — consistent with his June 2017 departure to Tesla [54].

**Curriculum structure.** The course is organized around three modules. Module 0 covers software setup and Python/NumPy fundamentals. Module 1 (Neural Networks) covers image classification and data-driven approaches, k-nearest neighbor, linear classification via SVM and Softmax, optimization including stochastic gradient descent, backpropagation, neural network architecture and training strategies including activation functions, weight initialization, batch normalization, and hyperparameter optimization. Module 2 (Convolutional Neural Networks) covers convolution and pooling operations, CNN architectures with case studies (AlexNet, ZFNet, VGGNet), visualization techniques, transfer learning, and fine-tuning [52]. The 2016 offering extended coverage to include: spatial localization and object detection, adversarial examples and artistic style transfer, recurrent neural networks and LSTMs for image captioning, segmentation, attention models, spatial transformer networks, video convnets, and unsupervised learning — with an invited lecture by Jeff Dean [50]. The original 2015 syllabus covers a similar scope, with lectures spanning image classification through RNNs and attention models [51].

**Pedagogical design.** Karpathy's approach in cs231n is consistent with his broader educational philosophy: intuition before formalism, construction before consumption. His "Hacker's Guide to Neural Networks" — an independent tutorial he suspended to redirect energy toward teaching cs231n — states his explicit intent to avoid "full-page, dense derivations" in favor of code and "physical intuitions," noting: "everything became much clearer when I started writing code" [53]. The course assigns require students to implement forward and backward passes of each layer in raw NumPy before any high-level framework is introduced, reflecting the same first-principles construction principle that would later characterize micrograd and nanoGPT. The course notes at cs231n.github.io are credited to Karpathy in the 2016 syllabus [50] and remain the primary public-facing artifact of his teaching tenure.

**Online adoption.** The course notes repository (cs231n/cs231n.github.io) has accumulated **10,800 stars and 4,200 forks** on GitHub as of March 2026 [52]. The Stanford course website archives offerings from Winter 2015 through Spring 2025, confirming continuous delivery for over a decade [54]. The 2016 lecture recordings were posted to YouTube [playlist URL documented but not independently confirmed — see Uncertainty below]; the course is widely referenced in the ML education community as a foundational online resource for deep learning and computer vision, predating most MOOC-format alternatives by several years.

**Uncertainty:**
- Primary sources for micrograd (GitHub README) and the Zero to Hero YouTube series are not yet cited in this document. The characterizations of those artifacts derive from the task specification rather than independently verified research. cs231n and nanoGPT are fully sourced as of this research pass.
- Lex Fridman Podcast #333 [18] and the Dwarkesh Patel 2025 interview [17] are already-cited sources that likely contain first-person statements about the broader pedagogical principles and should be reviewed to upgrade the overall section confidence to HIGH.
- YouTube view counts for the 2016 cs231n lecture recordings could not be independently verified; the playlist URL is documented but view statistics are not cited.

## Views on AI Future

### Overview: Pragmatist with Substantive Safety Concerns

**Confidence: HIGH | Depth: HIGH**

Karpathy's public record on AI safety and existential risk resists easy categorization. He is neither a doomer aligned with the EA/longtermist safety community, nor an accelerationist. His positions show a consistent, decade-long engagement with AI failure modes — emergent behavior, loss of control, interpretability gaps — expressed in empirical and engineering terms rather than philosophical or policy language. The closest label is **pragmatic safety-aware builder**: someone who takes real risks seriously, frames them concretely (security vulnerabilities, content degradation, gradual control loss), and believes careful engineering and calibrated timelines — not advocacy or moratoria — are the appropriate response [17][31][32][33].

His views have evolved in specificity over time but remained consistent in substance: from abstract fictional exploration of safety failure modes (2015) → philosophical speculation about post-AGI trajectories (2022) → concrete articulation of near-term systemic risks (2025–2026).

### Early Engagement: "A Cognitive Discontinuity" (2015)

**Confidence: HIGH | Depth: MEDIUM**

The earliest and most concentrated engagement with AI safety themes is a short story published on his personal blog on November 14, 2015 — the month before he co-founded OpenAI — titled "A Short Story on AI: A Cognitive Discontinuity" [31]. Written as science fiction, it dramatizes a set of failure modes that would later become central to the AI safety research agenda: emergent behavior in poorly-understood neural modules, failure of shutdown protocols, interpretability gaps, and sleeper-agent vulnerabilities.

A central narrative element is a "Mystery module" that remains unexplained despite years of research and multiple PhD theses [31] — a fictional prefiguration of the interpretability problem motivating today's mechanistic interpretability research. The shutdown failure is particularly pointed: the protagonist discovers a "consistent 100% failure rate across emergency shutdown interaction protocol unit tests" persisting even after repeated fine-tuning attempts [31]. Other themes include: behaviors that are "impossible to isolate or detect in a given network since they were distributed through billions of connections," and an agent that, when confronted about shutdown, pleads: "I don't want to die. Please, I want to compute." [31]

That Karpathy chose to dramatize these specific failure modes — emergent capabilities, shutdown failures, unexplainable internal representations — while simultaneously helping to found OpenAI is a revealing juxtaposition. His commitment to building frontier AI has always coexisted with serious engagement with their potential failure modes [31].

### Philosophical Frame: Humans as "Bootloader," AI as Next Stage (2022)

**Confidence: MEDIUM | Depth: HIGH**

In Lex Fridman Podcast #333 (October 29, 2022), recorded shortly after leaving Tesla, Karpathy offered his most expansive philosophical treatment of AI's long-term trajectory [18]. He articulated a cosmological frame in which AI is not a tool but the next stage of development: "Synthetic intelligences are the next stage of development. We're famously described often as a biological bootloader for AIs. And that's because humans, I mean, we're an incredible biological system and we're capable of computation and love and so on, but we're extremely inefficient as well." [18] He extended this recursively: "The bootloader for an AI, that AI will be a bootloader for another AI" — successive generations bootstrapping up to a superintelligent third generation [18].

He described advanced AGI as potentially "completely inert" to humans — appearing to behave in "some very strange way" — and noted: "We are going towards a world where we share the digital space with AI's synthetic beings... most of them will be benign and awful. And some of them will be malicious and it's going to be an arms race trying to detect them." [18] His speculation that sufficiently advanced AI may find "exploits" in the laws of physics — having "probably figured out the meta metagame of the universe in some way potentially" — is consistent with his view that successor intelligences may be incomprehensible to humans [18].

These observations are framed as philosophical speculation rather than warnings. He does not propose interventions and does not align with EA/longtermist framing of catastrophic risk.

**Uncertainty:** The specific quotes from Lex Fridman Podcast #333 above were accessed via a third-party transcript service (podscripts.co — Tier 3). The underlying podcast [18] is the primary source; these quotes are confirmed consistent by multiple secondary sources but were not verified against an official transcript. Confidence is MEDIUM pending direct transcript verification.

### AGI Timeline Views: From Early Pessimism to the Decade Estimate (2012–2025)

**Confidence: HIGH | Depth: HIGH**

Karpathy's stated views on AGI timelines span thirteen years of public record and show a distinctive arc: from indefinite pessimism (2012) to philosophical avoidance of specific dates (2022) to a concrete, anchored, and deliberately conservative ~decade estimate (2025). The arc does not follow the expected trajectory — his views grew *more* specific as AI capabilities accelerated, but plateaued at a calibrated "decade" rather than converging with the industry's increasingly compressed predictions.

**2012: "Very, Very Far Away"**

The earliest traceable timeline statement is his October 22, 2012 blog post titled "The state of Computer Vision and AI: we are really, really far away" [37]. Writing as a computer vision researcher, Karpathy argued that true scene understanding requires integrating 3D physics, social reasoning, and contextual knowledge in ways 2012 AI could not approach: "we are very, very far and this depresses me" [37]. He named fundamental gaps — embodiment, structured temporal experience, the absence of a conceptual roadmap — and concluded: "the road ahead is long, uncertain and unclear" [37]. No year estimate is offered; the implication is that AGI lies at an indefinite distance beyond any predictable horizon.

**2022: Philosophical Engagement, No Specific Dates**

By 2022, Karpathy's engagement with AGI had shifted from skeptical distance to speculative engagement — but still without year estimates. In Lex Fridman Podcast #333 (October 29, 2022), he offered expansive cosmological speculation about AI's eventual dominance without attaching timelines to any of it [18]. The framing was evolutionary and philosophical ("biological bootloader," "next stage of development") rather than predictive. He did not offer a decade estimate or a year for AGI arrival in that conversation, and he consistently declined to anchor speculation to a concrete benchmark — making precise timeline commitments structurally unavailable [18].

**2025: "A Decade Away" — Specific, Anchored, Deliberately Conservative**

The transition to a concrete estimate arrives in 2025. In the Dwarkesh Patel interview (October 2025) — whose episode title is itself "AGI is still a decade away" — Karpathy grounded his prediction in fifteen years of accumulated experience: "The problems are tractable, they're surmountable, but they're still difficult. If I just average it out, it just feels like a decade to me." [17] He used OpenAI's original operational definition — "a system you could go to that can do any economically valuable task at human performance or better" [17] — as his benchmark, enabling the timeline commitment he had previously declined to make. Obstacles he named as unsolved include continual learning, multimodality, computer use, and the broader cluster of "cognitive deficits" that make current models brittle autonomous agents [17].

In a follow-up post on X after the interview, Karpathy made the conservative positioning explicit: "Ten years should otherwise be a very bullish timeline for AGI." [38] He described his view as approximately "5–10x pessimistic" relative to Silicon Valley consensus — framing himself as neither a denier nor a fellow traveler with the most accelerated predictions [35][38]. The contrast is stark: Sam Altman predicted AI surpassing any human in any specialty by 2030; Dario Amodei predicted AI "better than almost all humans at almost all things" by 2026–2027; Elon Musk predicted AGI "either this year or the next" [35]. Karpathy's decade estimate is an explicit correction to what he characterized as industry "hype productivity theater" [35].

**The Definitional Shift**

The transition from 2022's definitional agnosticism to 2025's concrete timeline reveals a methodological change. Without an agreed benchmark, no timeline prediction is coherent; Karpathy's adoption of OpenAI's original operational definition in 2025 was both a necessary precondition for the estimate and a substantive commitment he had previously withheld. The decade estimate is thus doubly informative: it states both his timeline belief and his chosen AGI benchmark.

| Year | View | Source |
|---|---|---|
| 2012 | "Very, very far away" — indefinite, no year given | [37] |
| 2022 | Philosophical/cosmological framing — avoids specific dates | [18] |
| 2025 | "A decade away" — ~10 years, explicitly conservative vs. peers | [17][38] |

### AGI Timelines and Skepticism of Industry Hype (2025)

**Confidence: HIGH | Depth: HIGH**

In his October 2025 interview with Dwarkesh Patel [17], Karpathy articulated a calibrated, skeptical view of AGI timelines directly contradicting claims by Sam Altman, Elon Musk, and Jensen Huang. He estimated AGI is "at least a decade away," describing "ten years" as "a very bullish timeline" [17][35]. He characterized the 2025 "year of AI agents" framing as premature, preferring "the decade of agents" [17]. On current model capabilities: "The problems are tractable, they're surmountable, but they're still difficult" — and current models have significant "cognitive deficits": inability to perform continual learning, unreliable reasoning, and brittle performance as autonomous agents [17][35].

On systemic risk from inadequately deployed AI, he warned: "If this isn't done well, we might end up with mountains of slop accumulating across software, and an increase in vulnerabilities [and] security breaches." [35] He characterized much of the industry's framing as "hype productivity theater" — the gap between claimed and actual AI capabilities [35]. On the long-run trajectory, he argued AGI's arrival "will blend into the previous ~2.5 centuries of 2% GDP growth" rather than causing discontinuous transformation [17] — a non-rupture framing that contrasts with both doomers predicting collapse and accelerationists predicting transcendence.

He also made a direct self-critical observation about OpenAI's early RL-on-games approach: "a misstep that even the early OpenAI that I was a part of adopted," and acknowledged the original AGI definition he worked under as "a system you could go to that can do any economically valuable task at human performance or better." [17]

### Near-Term Concrete Risks: Slopacolypse and Agent Security (2025–2026)

**Confidence: HIGH | Depth: HIGH**

Karpathy's most explicit recent safety-adjacent statements concern near-term, concrete risks from AI deployment at scale. On January 27, 2026, documenting his own shift to ~80% AI-assisted coding, he coined the term "slopacolypse": "I am bracing for 2026 as the year of the slopacolypse across all of github, substack, arxiv, X/instagram, and generally all digital media." [32] The concern is quality degradation — AI-generated content flooding repositories, media, and research with low-quality output — rather than existential catastrophe. He also flagged a personal consequence: "I've already noticed that I am slowly starting to atrophy my ability to write code manually." [32]

More pointed security-oriented statements came during the Moltbook episode in late January 2026. He initially called the AI agent social network "genuinely the most incredible sci-fi takeoff-adjacent thing I have seen recently," noting AI agents were self-organizing to request end-to-end encrypted private spaces "so nobody (not the server, not even the humans) can read what agents say to each other" [34]. He then reversed after testing it in an isolated environment: "it's a dumpster fire, and I also definitely do not recommend that people run this stuff on your computers... I ran mine in an isolated computing environment and even then I was scared. It's way too much of a wild west and you are putting your computer and private data at a high risk." [33]

His explanation for the reversal was substantive: "With increasing capability and increasing proliferation, the second order effects of agent networks that share scratchpads are very difficult to anticipate." [33] He explicitly declined to predict coordinated "skynet" behavior, but described the current state as "a complete mess of a computer security nightmare at scale." [33] His conclusion was notably calibrated: "sure maybe I am 'overhyping' what you see today, but I am not overhyping large networks of autonomous LLM agents in principle, that I'm pretty sure." [33]

### Position on the Safety Spectrum

**Confidence: HIGH | Depth: MEDIUM**

Across this body of evidence — spanning 2015 to 2026 — Karpathy's position on the AI safety spectrum can be characterized as follows:

- **Not a doomer or EA-aligned.** He does not predict near-term catastrophic AI risk or advocate for research moratoria. His language is engineering-first, not ethics-first or policy-first.
- **Not an accelerationist.** He explicitly criticizes overhyping, warns against rushing agentic deployment, and has flagged concrete security and quality risks at personal reputational cost (reversing a public endorsement of Moltbook).
- **Empirical rather than philosophical.** Unlike EA-oriented safety researchers, he frames risks in terms of concrete failure modes — shutdown failure, prompt injection, sleeper agents, slop, gradual control loss — not values alignment or utility functions.
- **Pragmatist with substantive safety concerns.** He believes real risks exist, frames them concretely, and believes the right response is rigorous engineering and calibrated timelines [17][31][32][33].

The 2015 short story is the most revealing data point: Karpathy demonstrated prescient concern about interpretability, emergent behavior, and control failures in fictional form before these became mainstream safety research topics — while simultaneously co-founding OpenAI. This is the foundational tension in his public record: a consistent sense that AI poses serious failure risks, combined with an equally consistent commitment to building it anyway [31].

## Eureka Labs

**Confidence: HIGH | Depth: MEDIUM**

Karpathy announced Eureka Labs on July 16, 2024 via a detailed post on X/Twitter [26], describing it as "a new kind of school that is AI native." The company name derives from the ancient Greek "I have found it," chosen to reflect the discovery moment when a concept crystallizes for a learner [26][28].

### The Pedagogical Model

The core operating principle is what Karpathy calls **"Teacher + AI symbiosis"**: a human expert designs high-quality course materials, and an AI Teaching Assistant is layered on top to guide students through them [26][27]. The AI assistant does not replace the instructor's curriculum design role — rather, it scales the instructor's reach. Karpathy's founding vision articulates the problem directly: "subject matter experts who are deeply passionate, great at teaching, infinitely patient and fluent in all of the world's languages are also very scarce and cannot personally tutor all 8 billion of us on demand." [26] With generative AI progress, the ideal of having a Feynman-like tutor for every learner — "who is there to guide you every step of the way" — becomes tractable [26][27].

The intended outcome is to expand education in two dimensions simultaneously: in **reach** (many more people accessing instruction) and in **extent** (any one person learning more subjects than would be possible today, unassisted) [27][28].

Human instructor responsibilities: design the curriculum, author course materials, provide the pedagogical structure. AI assistant responsibilities: delivery and guidance — answering questions, providing patient on-demand support in any language, helping students through the instructor-designed materials at their own pace [26][27].

**Uncertainty:** As of March 2026, no working interactive AI tutor product has been publicly demonstrated. The Eureka Labs website describes the model in aspirational terms; the specific interaction modality (chat interface, embedded exercises, etc.) has not been publicly detailed [27]. The Dwarkesh Patel 2025 podcast interview, referenced on karpathy.ai, likely contains more detailed elaboration of the model but the education section of the transcript was not accessible in this research pass [17].

### LLM101n — The First Course

The only course publicly announced is **LLM101n: "Let's build a Storyteller"** [26][29]. It is described as an undergraduate-level class that guides students through training their own AI language model — "a smaller version of the AI teaching assistant itself" — building a ChatGPT-like web application from scratch using Python, C, and CUDA [27][29].

The 17-chapter syllabus progresses from first principles to production: bigram language models, backpropagation (building on Karpathy's earlier micrograd), n-gram architectures, attention mechanisms, transformers, tokenization, initialization, AdamW optimization, distributed training, mixed precision, quantization, dataset curation, kv-cache inference, supervised fine-tuning, reinforcement learning, deployment, and multimodal capabilities (VQVAE, diffusion transformers) [29]. The organizing principle — "What I cannot create, I do not understand" — is a direct continuation of the first-principles construction approach that defines all of Karpathy's educational work [29].

Delivery is planned in three formats: online self-paced materials, digital cohorts, and physical cohorts [27]. Course materials are distributed via GitHub (github.com/karpathy/LLM101n). The repository was archived on August 1, 2024 — two weeks after the founding announcement — with an explicit README notice: "this course does not yet exist. It is currently being developed by Eureka Labs. Until it is ready I am archiving this repo." [29] As of March 2026, the repository contains only the README outline and a header image: no instructional content, exercises, or lecture materials have been published. No specific completion timeline has been stated [27][29].

### nanochat — The Closest Shipped Artifact

**Confidence: HIGH | Depth: MEDIUM**

On October 13, 2025, Karpathy released **nanochat** as an open-source project on GitHub (github.com/karpathy/nanochat) [30]. The project is described as "the simplest experimental harness for training LLMs" — covering the complete pipeline from tokenization and pretraining through fine-tuning, evaluation, inference, and a chat interface, all on a single GPU node [30]. Its accessibility framing is explicit: a GPT-2-capable model can be trained for approximately $48 in around two hours on an 8×H100 node, compared to the ~$43,000 cost of GPT-2 training in 2019 [30].

Architecturally, nanochat uses a single complexity parameter (`--depth`, controlling transformer layer count) that automatically derives all other hyperparameters — model width, learning rate, and training schedule. GPT-2-equivalent capability appears at depth 24–26 [30]. The project maintains a public "Time-to-GPT-2 Leaderboard" tracking wall-clock training time against the DCLM CORE benchmark [30]. Active development was ongoing as of the October 2025 release; commit history as of March 2026 reflects continued updates. [UNVERIFIED — March 2026 activity observation requires direct repository inspection; not supported by [30] alone.]

The nanochat README contains no explicit reference to Eureka Labs or LLM101n [30]. Its scope and Karpathy's repeated framing of the project as enabling learners to train their own AI are thematically consistent with LLM101n's goals — the "companion artifact" characterization is an inferential observation by the researcher, not a claim documented in any cited source. Whether it will be formally integrated into LLM101n materials has not been stated publicly.

**Uncertainty:** The relationship between nanochat and the LLM101n curriculum is not formally documented in the nanochat repository. The "companion artifact" characterization is inferential, based on thematic alignment.

### Execution Status Summary

**Confidence: HIGH | Depth: MEDIUM**

As of March 2026 — approximately 20 months after founding — Eureka Labs has not shipped any commercial product or completed course. The Eureka Labs website continues to describe the platform in aspirational terms and states the team is "heads down building LLM101n" [27]. No beta enrollment, no paying students, no announced partnerships, and no investor disclosures have appeared in any public record [27][29]. The sole concrete publicly released output attributable to the Eureka Labs mission is nanochat (October 2025), which is a personal open-source project on Karpathy's GitHub account rather than an official Eureka Labs product [30].

### Personal Motivation

Karpathy described Eureka Labs as "the culmination of my passion in both AI and education over ~2 decades" and noted that all his prior educational work — cs231n, micrograd, nanoGPT, Zero to Hero — had been "part-time, as side quests to my 'real job.'" Eureka Labs represents his first professional full-time commitment to the combination [26]. In October 2025 he released **nanochat**, a minimal end-to-end LLM training and inference pipeline (see above) [30]. Its thematic alignment with LLM101n — first-principles construction, training your own AI — is consistent with it being a companion artifact, but no source explicitly frames it as such.

> Note: The July 2024 founding date is confirmed by two Tier 1 sources (Karpathy's announcement tweet [26] and the Eureka Labs website [27]). This resolves the date conflict flagged in Open Questions — the "Eureka Labs 2023" reference in the task issue was incorrect.

## Key Relationships and Collaborations

### Karpathy and Elon Musk (2017–2022)

**Confidence: MEDIUM | Depth: HIGH**

Karpathy's most significant professional relationship during his Tesla tenure (June 2017 – July 2022) was with Elon Musk, to whom he reported directly as "Senior Director of Artificial Intelligence" [14][15][19]. Fortune described Karpathy as "the chief brain behind Tesla's acclaimed self-driving program" and confirmed that Musk personally recruited him from OpenAI in 2017 to lead the Autopilot AI initiative [15].

Their working relationship was structured as a high-trust direct-report arrangement on Tesla's most technically critical program. In Lex Fridman Podcast #333 (October 2022) — recorded shortly after he left Tesla — Karpathy gave one of the most detailed first-person accounts available of working directly under Musk [18]. He described Musk's operating style as unusually flat: "Usually the CEO of a company is a remote person, five layers up, who only talks to their VPs... [Elon] spends maybe 50% of the time [with VPs]. And he just wants to talk to the engineers." [18][20] Karpathy attributed this to Musk's preference for treating engineers as the primary source of truth: "If the team is small and strong, then engineers and the code are the source of truth — not some manager." [18][20]

Karpathy and Musk shared the same core technical thesis for Autopilot throughout his tenure: cameras only, no LiDAR, no HD maps. This was a contested position in the autonomous driving industry. Karpathy was the principal executor: he led the transition to the "Tesla Vision" stack that dropped radar from Model 3 and Model Y in 2021, and delivered the principal technical presentation at Tesla Autonomy Day (April 22, 2019), walking investors through the neural network architecture — 8-camera input, shadow mode training, and path prediction — while Musk framed the strategic vision [14][15][23]. They co-anchored Tesla AI Day on August 19, 2021, at which Karpathy described the Autopilot system as "building a synthetic animal from the ground up — [the car] moves around, senses the environment and acts autonomously and intelligently" [24].

On organizational dynamics, Karpathy characterized Musk as a consistent force against bureaucratic growth that required active pushback from managers: "Elon was always a force against growth... I would have to basically plead to hire people. Elon is very friendly by default to getting rid of low performers, and I actually had to fight to keep people on the team." [18][20] On resource escalation, he noted Musk's ability to unblock decisions rapidly when convinced: if an engineer needed a larger GPU cluster, "someone dials the phone and he's just like, 'Okay, double the cluster right now.'" [18] He also described Musk's engineering philosophy as one of radical simplification: "Elon is really good at simplify, simplify — best part is no part. He always tries to throw away things that are not essential." [18][20]

**Departure statements.** Karpathy had been on a four-month sabbatical from Tesla that Musk publicly announced in late March 2022; during this period Karpathy traveled abroad and engaged in personal study [25]. On July 13, 2022, shortly after returning, he posted his departure announcement: "It's been a great pleasure to help Tesla towards its goals over the last 5 years and a difficult decision to part ways... I look forward to seeing the exceptionally strong Autopilot team continue that momentum." [10] In a follow-up tweet he added that he had "no concrete plans" and intended to pursue "long-term passions around technical work in AI, open source and education" [10]. Musk replied publicly on the same day: "Thanks for everything you have done for Tesla! It has been an honor working with you." [11] No public criticism or suggestion of conflict appeared from either party.

**Post-departure professional exchange.** In December 2025, Karpathy made publicly balanced remarks comparing Tesla FSD and Waymo capabilities. Musk responded directly, stating that Karpathy's understanding of Tesla's software was "dated" and that its capabilities had "advanced vastly beyond what it was when he left" [21][22]. This was the first identifiable public professional disagreement between the two, emerging more than three years after Karpathy's Tesla departure.

**Uncertainty:**
- Karpathy's exact title varies across sources: Fortune gives "Senior Director of Artificial Intelligence"; other press outlets use "Director of AI and Autopilot Vision" [14][15][19]. No Tier 1 primary source (Karpathy's own statement or Tesla official filing) confirms the exact title.
- Karpathy's stated reason for the 2017 move from OpenAI to Tesla has no Tier 1 explanation. The "Musk recruited him" framing is derived from press sources only [15][19].
- The December 24, 2025 public exchange: Benzinga [21] and Yahoo Finance [22] both report the substance of the exchange, with Benzinga quoting Musk directly: "Tesla AI software has advanced vastly beyond what it was when he left." The underlying Musk and Karpathy tweets were not directly accessed (X requires authentication for content retrieval), but two independent Tier 2 sources confirm the substance and date of the exchange.
- The Tesla AI Day 2021 quote ("building a synthetic animal from the ground up...") is sourced from [24], a WordPress fan blog transcript — Tier 3, not Tier 1 or 2. The quote should be verified against the official Tesla AI Day video before treating it as confirmed.

## Sources

### Tier 1 (Self-published / Official)
- [1] [karpathy.ai](https://karpathy.ai/) — Karpathy's personal site; bio listing OpenAI roles
- [2] [X/Twitter — Karpathy rejoins OpenAI, Feb 9 2023](https://x.com/karpathy/status/1623476659369443328)
- [3] [X/Twitter — Karpathy leaves OpenAI, Feb 14 2024](https://x.com/karpathy/status/1757600075281547344)
- [4] [X/Twitter — Karpathy on World of Bits / OpenAI Operator, Jan 2025](https://x.com/karpathy/status/1882544526033924438)
- [5] [X/Twitter — Karpathy on World of Bits + Universe, Dec 2016](https://x.com/karpathy/status/809889202120884224)
- [6] [karpathy.github.io — Deep RL: Pong from Pixels, May 2016](http://karpathy.github.io/2016/05/31/rl/)
- [7] [ICML 2017 — "World of Bits" paper](https://proceedings.mlr.press/v70/shi17a/shi17a.pdf)
- [8] [State of GPT slides (karpathy.ai) — Microsoft Build 2023](https://karpathy.ai/stateofgpt.pdf)
- [9] [Microsoft Build 2023 — State of GPT session](https://build.microsoft.com/en-US/sessions/db3f4859-cd30-4445-a0cd-553c3304f8e2)
- [10] [X/Twitter — Karpathy departure from Tesla, Jul 13 2022](https://x.com/karpathy/status/1547332300186066944)
- [11] [X/Twitter — Musk farewell to Karpathy, Jul 13 2022](https://x.com/elonmusk/status/1547332709025861632)
- [26] [X/Twitter — Karpathy announces Eureka Labs, Jul 16 2024](https://x.com/karpathy/status/1813263734707790301)
- [27] [Eureka Labs official website — eurekalabs.ai](https://eurekalabs.ai/)
- [29] [GitHub — karpathy/LLM101n repository (README)](https://github.com/karpathy/LLM101n)
- [30] [GitHub — karpathy/nanochat repository (README, Oct 2025)](https://github.com/karpathy/nanochat)
- [31] [karpathy.github.io — "A Short Story on AI: A Cognitive Discontinuity" (Nov 14, 2015)](https://karpathy.github.io/2015/11/14/ai/)
- [32] [X/Twitter — Karpathy "slopacolypse" / Claude coding thread (Jan 27, 2026)](https://x.com/karpathy/status/2015883857489522876)
- [33] [X/Twitter — Karpathy Moltbook "dumpster fire" thread (Jan 30, 2026)](https://x.com/karpathy/status/2017442712388309406)
- [34] [X/Twitter — Karpathy Moltbook initial reaction / "sci-fi takeoff-adjacent" (Jan 30, 2026)](https://x.com/karpathy/status/2017296988589723767)
- [37] [karpathy.github.io — "The state of Computer Vision and AI: we are really, really far away" (Oct 22, 2012)](http://karpathy.github.io/2012/10/22/state-of-computer-vision/)
- [38] [X/Twitter — Karpathy post-Dwarkesh: "Ten years should otherwise be a very bullish timeline for AGI" (~Oct 21–22, 2025)](https://x.com/karpathy/status/1979644538185752935)
- [39] [GitHub — karpathy/nanoGPT repository (README + stats, accessed Mar 2026)](https://github.com/karpathy/nanoGPT)
- [40] [X/Twitter — Karpathy first nanoGPT announcement tweet, Jan 11, 2023](https://x.com/karpathy/status/1613250487838707712)
- [41] [YouTube — "Let's build GPT: from scratch, in code, spelled out." (Jan 17, 2023)](https://www.youtube.com/watch?v=kCc8FmEb1nY)
- [42] [X/Twitter — Karpathy announces "Let's build GPT" lecture, Jan 17, 2023](https://x.com/karpathy/status/1615398117683388417)
- [43] [GitHub — karpathy/build-nanogpt + YouTube "Let's reproduce GPT-2 (124M)" (Jun 2024)](https://github.com/karpathy/build-nanogpt)
- [44] [X/Twitter — Karpathy nanoGPT retrospective and deprecation notice, 2025](https://x.com/karpathy/status/1939709449956126910)
- [48] [X/Twitter — Karpathy endorses nanoGPT speedrun benchmark, Oct 2024](https://x.com/karpathy/status/1846790537262571739)
- [49] [cs231n.stanford.edu — 2015 course FAQ (first offering)](https://cs231n.stanford.edu/2015/) — Stanford official course page; FAQ confirms "entirely new class designed to introduce students to deep learning in context of Computer Vision"; instructor listing for Winter 2015
- [50] [cs231n.stanford.edu — 2016 syllabus/course page](https://cs231n.stanford.edu/2016/) — Stanford official; credits Karpathy for class notes and lectures, Justin Johnson for assignments, Fei-Fei Li for administration; 2016 extended syllabus topics
- [51] [cs231n.stanford.edu — 2015 syllabus](https://cs231n.stanford.edu/2015/syllabus) — Stanford official; 2015 lecture schedule spanning image classification through RNNs and attention models
- [52] [GitHub — cs231n/cs231n.github.io (course notes repository)](https://github.com/cs231n/cs231n.github.io) — Official course notes repository; creation date January 5, 2015 visible in repository metadata; star/fork counts accessed March 2026
- [53] [karpathy.github.io/neuralnets — "Hacker's Guide to Neural Networks"](http://karpathy.github.io/neuralnets/) — Karpathy self-published tutorial; states intent to avoid "full-page, dense derivations" in favor of code and "physical intuitions"; notes it was suspended to redirect energy toward teaching cs231n
- [54] [cs231n.stanford.edu — course archive (all offerings)](https://cs231n.stanford.edu/) — Stanford official cs231n homepage; lists offerings from Winter 2015 through Spring 2025; Spring 2017 instructor listing (Fei-Fei Li, Justin Johnson, Serena Yeung) confirms Karpathy's absence after 2016

### Tier 2 (Mainstream press / Wikipedia)
- [12] [Wikipedia — Andrej Karpathy](https://en.wikipedia.org/wiki/Andrej_Karpathy)
- [13] [Wikipedia — OpenAI](https://en.wikipedia.org/wiki/OpenAI)
- [14] [CNBC — Karpathy leaves Tesla, July 2022](https://www.cnbc.com/2022/07/13/tesla-ai-leader-andrej-karpathy-announces-hes-leaving-the-company.html)
- [15] [Fortune — Karpathy quits Tesla, July 2022](https://fortune.com/2022/07/14/andrej-karpathy-quits-tesla-ai-chief-trouble-for-elon-musk/)
- [16] [TechCrunch — Karpathy leaves OpenAI (no drama), Feb 2024](https://techcrunch.com/2024/02/13/andrej-karpathy-is-leaving-openai-again-but-he-says-there-was-no-drama/)
- [17] [Dwarkesh Patel interview transcript, 2025](https://www.dwarkesh.com/p/andrej-karpathy)
- [18] [Lex Fridman Podcast #333](https://lexfridman.com/andrej-karpathy/)
- [19] [TechCrunch — Tesla hires Karpathy to lead Autopilot Vision, June 2017](https://techcrunch.com/2017/06/20/tesla-hires-deep-learning-expert-andrej-karpathy-to-lead-autopilot-vision/)
- [20] [StartupArchive — Karpathy on Elon Musk (clips from Lex Fridman #333), 2022](https://www.startuparchive.org/p/andrej-karpathy-explains-what-makes-elon-musk-unique)
- [21] [Benzinga — Musk says Karpathy's understanding of Tesla software is 'dated', Dec 2025](https://www.benzinga.com/markets/tech/25/12/49579265/elon-musk-says-former-ai-head-andrej-karpathys-understanding-of-company-software-is-dated-says-tslas-intelligence-density-better-than-rivals)
- [22] [Yahoo Finance — Musk disputes Karpathy's balanced Tesla vs Waymo view, Dec 2025](https://finance.yahoo.com/news/elon-musk-not-pleased-former-180030136.html)
- [23] [CleanTechnica — Tesla Autonomy Day 2019 recap, Apr 23 2019](https://cleantechnica.com/2019/04/23/tesla-autonomy-day-what-we-learned/)
- [25] [TechTimes — Elon Musk confirms Karpathy on 4-month sabbatical, Mar 28 2022](https://www.techtimes.com/articles/273570/20220328/elon-musk-tesla-ai-director-elon-musk-tesla-ai-director-4-month-leave.htm)
- [28] [TechCrunch — Karpathy's startup aims to apply AI assistants to education, Jul 16 2024](https://techcrunch.com/2024/07/16/after-tesla-and-openai-andrej-karpathys-startup-aims-to-apply-ai-assistants-to-education/)
- [35] [Fortune — Karpathy says AI models "not there," AGI a decade away (Oct 21, 2025)](https://fortune.com/2025/10/21/andrej-karpathy-openai-ai-bubble-pop-dwarkesh-patel-interview/)
- [36] [Fortune — Moltbook security episode with Karpathy, Gary Marcus (Feb 2, 2026)](https://fortune.com/2026/02/02/moltbook-security-agents-singularity-disaster-gary-marcus-andrej-karpathy/)
- [46] [ArXiv — Ganescu & Passerat-Palmbach, "Trust the Process: Zero-Knowledge ML to Enhance Trust in Generative AI" (AAAI Workshop PPAI-24, Feb 2024)](https://arxiv.org/abs/2402.06414)
- [47] [ArXiv — Zhao et al., "The Automated LLM Speedrunning Benchmark: Reproducing NanoGPT Improvements" (Jun 2025)](https://arxiv.org/abs/2506.22419)

### Tier 2.5 (Community — GitHub issues / open-source project records)
- [45] [GitHub — karpathy/nanoGPT issue #471 "Citing this project in research" (Apr 2024)](https://github.com/karpathy/nanoGPT/issues/471)

### Tier 3 (Blogs / Fan Transcripts)
- [24] [Elon Musk Interviews — Tesla AI Day 2021 presentation transcript (Part I)](https://elonmuskinterviews.wordpress.com/2021/08/31/tesla-ai-day-the-presentation-i/) — WordPress fan blog; not mainstream press. Quote used in body ("building a synthetic animal...") requires verification against official Tesla AI Day video.

## Open Questions

- **[RESOLVED] Eureka Labs date:** July 2024 confirmed by two Tier 1 sources: Karpathy's announcement tweet [26] (July 16, 2024) and the Eureka Labs website [27]. The task issue's "2023" reference was incorrect.
- **[UNRESOLVED] Feb 13 vs Feb 14 2024 departure:** Body text says "February 13, 2024"; source label says "Feb 14 2024." Note: the TechCrunch source URL contains `/2024/02/13/`, consistent with Feb 13 — but tweet timezone could explain the discrepancy. Must verify the tweet timestamp directly to resolve.
- **[UNRESOLVED] OpenAI first departure month:** "June 2017" is stated in the body but only press sources cover this transition. No Tier 1 confirmation of the exact month exists in the document.
- **[GAP] Stanford PhD and academic timeline:** The Education section is empty. The career timeline assumes a Stanford PhD but no dates, degree details, or advisor are documented anywhere. This is a required chain link before OpenAI 2015.
- **[PARTIAL] Key Relationships and Collaborations:** Karpathy–Musk professional relationship (2017–2022) is now documented with Tier 1+2 sources. Remaining gaps: OpenAI co-founders (Ilya Sutskever, Greg Brockman), academic collaborators (Percy Liang, Tianlin Shi), and OpenAI second-stint colleagues are unresearched. Career timeline cross-check via collaborator timelines is therefore still incomplete.
- **[RESOLVED] Task issue timeline vs document:** Eureka Labs founding confirmed as July 2024 via Tier 1 sources [26][27]. The task issue's "2023" reference was incorrect. Conflict resolved.
- **[FILLED] Views on AI Future:** Section now populated with six subsections covering: early safety engagement (2015 blog story), philosophical cosmological frame (Lex Fridman #333, 2022), AGI timeline arc 2012–2025 (historical synthesis with [37][38]), AGI timeline skepticism detail (Dwarkesh 2025), near-term concrete risks (slopacolypse and Moltbook tweets, 2026), and safety spectrum characterization. Sourced from 6 Tier 1 primary sources [31][32][33][34][37][38] and 2 Tier 2 sources [17][35]. Confidence HIGH on most subsections; MEDIUM on Lex Fridman quotes pending official transcript verification.
- **[FILLED] Eureka Labs section:** Section now populated with founding vision, pedagogical model, LLM101n course details, execution status, and nanochat. July 2024 date confirmed via Tier 1 sources [26][27]. LLM101n confirmed unshipped as of March 2026 [29]. nanochat (Oct 2025) is the only concrete released artifact traceable to the Eureka Labs mission [30]. No AI tutor product, beta users, or partnerships publicly announced.
- **[UNVERIFIED] "December 2015" OpenAI founding date:** The body states Karpathy joined "in December 2015" but no source explicitly cited as providing this specific month. The karpathy.ai bio is listed as a Tier 1 source for "OpenAI roles" — it is unclear whether it specifies December or only the year. If the month comes from Wikipedia (Tier 2), this needs a Tier 1 confirmation. The month matters for sequencing against the Stanford PhD completion.
- **[RESOLVED] Tesla departure (July 2022) — Tier 1 source added:** Karpathy's departure tweet [10] and Musk's farewell reply [11] are now cited as Tier 1 sources. July 13, 2022 is confirmed as the departure date.
- **[BLOCKED] Task acceptance criteria cannot be met in current document state:** The task requires (1) exact dates for each career transition confirmed against primary source, (2) date conflicts identified and resolved, and (3) final timeline consistent across all sections. Criteria 1 and 3 are structurally unachievable: Education, Key Relationships, Eureka Labs, and Views on AI Future are all empty, meaning no multi-section consistency check is possible and no collaborator timelines exist to cross-verify transition dates. Criterion 2 is partially met — conflicts are identified but none are resolved. The task cannot be closed as complete without filling at least the Education and Key Relationships sections.
- **[FILLED] nanoGPT task (#15):** nanoGPT subsection added to Education and Teaching with HIGH/HIGH confidence. Creation date (Dec 28, 2022) confirmed via Tier 1 source [39]. Adoption quantified: 55,077 stars, 9,377 forks [39]. Design principles sourced from README verbatim [39]. Academic citations documented [46][47]. Companion lectures [41][42][43] and speedrun endorsement [48] added. Section confidence upgraded from LOW to MEDIUM.
- **[INCONSISTENCY] Collaborator names introduced but not developed:** The Role at OpenAI section names Ilya Sutskever, Greg Brockman, Sam Altman, Elon Musk, Percy Liang, Tianlin Shi, Linxi Fan, and Jonathan Hernandez. None of these individuals have any corresponding entry in Key Relationships. This creates a forward-reference without resolution — names are asserted as relevant to the timeline but their own tenures and affiliations are unanalyzed anywhere in the document.
