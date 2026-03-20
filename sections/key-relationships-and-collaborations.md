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

### Ilya Sutskever

Ilya Sutskever is the figure in Karpathy's professional network who most sharply defines the contrast between Karpathy's engineering-pragmatist stance on AI and the safety-first worldview that has come to anchor one wing of the field. They were co-founders of OpenAI in December 2015, worked together across two separate stints, and have since diverged publicly and structurally on the question of when — and how urgently — AGI must be prepared for.

**Background and shared intellectual lineage.** Both Karpathy and Sutskever passed through the University of Toronto and Geoffrey Hinton's orbit, though not simultaneously as mentor and student with each other. Karpathy completed his BSc at Toronto (2005–2009) and attended Hinton's classes and reading groups [12]. Sutskever was Hinton's PhD student and co-developed AlexNet (2012) with Hinton and Alex Krizhevsky — the paper that catalyzed the deep learning era in computer vision [13]. This shared ancestry in the Hinton school gives both researchers a common foundation, even though their direct professional relationship began only at OpenAI.

**Confidence: HIGH | Depth: HIGH**

---

#### Co-Founders at OpenAI: Asymmetric Roles (2015–2017, 2023–2024)

OpenAI was incorporated in December 2015 with eleven founding members including Sam Altman, Elon Musk, Greg Brockman, Sutskever, and Karpathy [13]. Their roles were asymmetric from the outset: Sutskever joined as Chief Scientist — a formal research leadership position — while Karpathy joined as a Research Scientist, a technical contributor role [1][13]. Sutskever had left Google (following Google's acquisition of his and Hinton's DNNResearch startup after AlexNet) to take the Chief Scientist post. Karpathy was still completing his Stanford PhD under Fei-Fei Li when he joined and stayed from December 2015 through June 2017, when he departed for Tesla [19].

Both returned to OpenAI in 2023: Karpathy rejoined in February 2023 to lead work on midtraining and synthetic data generation [2]; Sutskever had never formally left but returned to a more circumscribed role following the November 2023 board crisis, in which he had initially voted to remove Sam Altman before co-signing the employee letter demanding reinstatement [13]. Karpathy departed again in February 2024 with no stated drama [3]; Sutskever departed in May 2024 [103].

No jointly authored research papers from either overlap period have been found. Karpathy's most productive publication period predates OpenAI (Stanford, 2012–2016), and his main OpenAI-era research output — the "World of Bits" paper (ICML 2017) — lists Sutskever as neither co-author nor acknowledgment [7]. The organizational relationship between them (Sutskever as Chief Scientist, Karpathy as research contributor) was documented by their titles but not by any co-authored artifact in the public record.

**Confidence: HIGH | Depth: MEDIUM**

**Uncertainty:** No primary source documents the nature of their working relationship at OpenAI — whether Sutskever directed Karpathy's research agenda, collaborated informally, or operated in parallel domains. The absence of co-authorship is documented; the nature of the day-to-day relationship is not.

---

#### Founding Safe Superintelligence: Sutskever's Post-OpenAI Move

On June 19, 2024 — four months after Karpathy's own OpenAI departure — Sutskever announced Safe Superintelligence Inc. (SSI) via Twitter: "We will pursue safe superintelligence in a straight shot, with one focus, one goal, and one product" [104]. SSI's website states its mission directly: "Building safe superintelligence (SSI) is the most important technical problem of our time. We have started the world's first straight-shot SSI lab, with one goal and one product: a safe superintelligence" [102]. The company was co-founded with Daniel Gross (Y Combinator partner) and Daniel Levy, headquartered across Palo Alto and Tel Aviv, and raised $1B in its September 2024 Series A from Sequoia, a16z, and DST Global, reaching a $30B+ valuation by March 2025 [108].

No documented public statement by Karpathy about SSI's founding, mission, or Sutskever's departure from OpenAI has been found. Karpathy's February 2024 departure tweet [3] — posted three months before Sutskever's — contains no mention of Sutskever, and his October 2025 Dwarkesh Patel podcast, which covered AGI timelines and current AI limitations at length, contains no mention of Sutskever or SSI [17].

**Confidence: HIGH | Depth: HIGH**

---

#### The AGI Divergence: Timeline and Safety Posture

The most substantive documented contrast between Karpathy and Sutskever is not interpersonal but intellectual: they have both made explicit, public statements about AGI timelines and safety posture that point in different directions.

**Karpathy: decade estimate, pragmatist framing.** In his October 2025 Dwarkesh Patel interview, Karpathy put AGI "about a decade away," using OpenAI's original operational benchmark — a system capable of performing any economically valuable task at human performance or better [17]. On Twitter shortly after, he described himself as "5–10x pessimistic relative to Silicon Valley consensus" and characterized near-term AGI predictions as "hype productivity theater" [38]. His framing is empirical and capability-focused: current models have significant cognitive deficits, improvement is real but bounded by tractable engineering challenges, and the transition to AGI will be gradual rather than discontinuous.

**Sutskever: 5 to 20 years, safety-first framing.** In his November 2025 Dwarkesh Patel interview, Sutskever gave a direct timeline estimate: "I think like 5 to 20" years [106]. He described superintelligence not as a system that already knows every job, but one capable of *learning* to do every job — "a superintelligent 15-year-old" — deployed incrementally. He characterized current models as generalizing "dramatically worse than people," echoing Karpathy's diagnosis of limitations while drawing a more urgent conclusion about the pace of breakthrough. At NeurIPS 2024, he was deliberately noncommittal on specific timing but explicit about direction: "I'm not saying how... and I'm not saying when. I'm saying that it will" [107] — **citation unverified: [107] is a June 2024 article and cannot contain December 2024 NeurIPS remarks; a contemporaneous NeurIPS 2024 source is needed**.

On safety posture, the divergence is structural. Sutskever signed the May 2023 Center for AI Safety statement that "mitigating the risk of extinction from AI should be a global priority alongside other societal-scale risks such as pandemics and nuclear war" [105]. SSI's stated approach treats safety and capabilities as "technical problems to be solved through revolutionary engineering and scientific breakthroughs" [102] — a safety-by-design posture. Karpathy is not a documented signatory of the CAIS statement. His public risk framing is concrete and empirical — focused on current model limitations, misuse vectors, and near-term deployment failures — rather than organized around extinction-level risk scenarios. He has not publicly aligned with effective altruist or longtermist framings of AI safety.

The timelines nominally overlap (Sutskever's lower bound of 5 years and Karpathy's estimate of 10 years are not mutually exclusive), but the framing and urgency differ substantially. Karpathy emphasizes the distance and the engineering difficulty; Sutskever emphasizes the arrival's certainty and the need to build safety-first infrastructure now, regardless of exact timing.

**Confidence: HIGH | Depth: HIGH**

---

#### Scope of the Relationship and Limits of the Record

The Karpathy–Sutskever relationship is primarily structural: they were co-founders and colleagues across two OpenAI stints, share a deep learning intellectual lineage through Hinton, and have publicly staked out contrasting positions on the urgency and framing of AGI. No direct public exchanges between them — no joint interviews, shared panels, or documented Twitter interactions — have been found in indexed sources from 2015 through March 2026. Their intellectual divergence is therefore documented through parallel but non-intersecting public record, not through a documented debate or exchange.

**Confidence: MEDIUM | Depth: MEDIUM**

**Uncertainty:** Whether Karpathy and Sutskever collaborated informally during their OpenAI overlaps (2015–2017, 2023–2024) remains undocumented. Their public silence about each other — no Karpathy comment on SSI, no Sutskever comment on Eureka Labs — may reflect professional discretion, distinct audiences, or simply the absence of direct friction rather than genuine intellectual distance.

---

### The Formal AI Safety Research Community

The most precise characterization of Karpathy's relationship with the formal AI safety research community is documented non-engagement: no co-authorship, no signed statements, no named public interactions, and no appearances alongside canonical safety researchers in any indexed source from 2015 through March 2026. This finding is not a research gap but a structural feature of his public record — and it is meaningful given that Karpathy was physically co-located with the AI safety research community at OpenAI during both of his stints there.

**Confidence: HIGH | Depth: HIGH**

---

#### The CAIS Extinction Risk Statement: A Structural Absence

In May 2023, the Center for AI Safety released a one-sentence public statement — "Mitigating the risk of extinction from AI should be a global priority alongside other societal-scale risks such as pandemics and nuclear war" — that attracted signatures from hundreds of AI researchers and executives [105]. Among the signatories were several of Karpathy's closest OpenAI co-founders and colleagues: Ilya Sutskever, Sam Altman, John Schulman, and Wojciech Zaremba [105][128]. Karpathy's name is absent from the full public signatory list [128].

The absence is structurally significant in context. Karpathy was during his second OpenAI stint when the statement circulated — he had rejoined in February 2023 [2] and would not depart until February 2024 [3]. He was therefore an active OpenAI employee when the statement was published and when his immediate colleagues were signing it. No Tier 1 source documents his decision not to sign or any public comment on the statement itself.

**Confidence: HIGH | Depth: HIGH**

---

#### "Concrete Problems in AI Safety": Parallel but Separate

The 2016 paper "Concrete Problems in AI Safety" (arXiv:1606.06565), authored by Dario Amodei, Chris Olah, Jacob Steinhardt, Paul Christiano, John Schulman, and Dan Mané, is the canonical technical document of the OpenAI-era safety research program [130]. All six authors were affiliated with OpenAI or Stanford at the time of publication; Schulman was a colleague of Karpathy's at OpenAI during his first stint [13]. Karpathy is neither an author nor named in the acknowledgments of the paper [130]. No co-authored work between Karpathy and any of the six authors has been found in the public record.

**Confidence: HIGH | Depth: HIGH**

---

#### The Interpretability Genealogy: Intellectual Connection Without Personal Engagement

The one domain where a documented intellectual thread connects Karpathy to the formal safety research community is neural network interpretability — and it runs through the research record rather than any personal relationship.

Karpathy's 2015 paper "Visualizing and Understanding Recurrent Networks" (arXiv:1506.02078, co-authored with Johnson and Li) analyzed trained LSTM character models and found that approximately 5% of cells had developed interpretable, humanly-describable functions: tracking position within quotation marks, line length, and code indentation depth [68]. The "unreasonable effectiveness" blog post [82] popularized the finding. The paper is cited in the interpretability literature — a 2024 EMNLP survey on NLP interpretability research includes it as historical precedent [131] — and the question it posed (can we identify what individual neurons have learned?) is the empirical foundation of the mechanistic interpretability research program associated with Chris Olah and Anthropic's interpretability team.

However, the connection is intellectual-genealogical rather than collaborative. Olah's major interpretability papers — including the Distill.pub "Zoom In" article (2020), "Toy Models of Superposition" (Anthropic, 2022) [84], and "Towards Monosemanticity" (Anthropic, 2023) [85] — do not cite Karpathy's 2015 LSTM paper [84][85]. Karpathy's blog posts and podcast appearances from 2022 through early 2026 contain no mentions of Olah, "mechanistic interpretability," circuits-style analysis, or Anthropic's interpretability program. No documented acknowledgment from either direction has been found.

**Confidence: HIGH | Depth: MEDIUM**

**Uncertainty:** It is not established whether this mutual non-acknowledgment reflects deliberate distance, simple parallel development, or the typical citation gaps that emerge between adjacent sub-fields that share a question but not a methodology. Karpathy's interpretability work used direct visualization and probing; Olah's subsequent work developed the circuits hypothesis and sparse autoencoders — different methodological commitments even if the underlying empirical question overlaps.

---

#### Departure Contrast: Karpathy vs. Jan Leike

A structurally informative data point is the contrast between Karpathy's second OpenAI departure (February 2024) and Jan Leike's departure three months later (May 2024). Leike, who led OpenAI's alignment team, published an explicit public statement criticizing OpenAI's safety culture: "safety culture and processes have taken a backseat to shiny products" [133]. Karpathy's February 2024 departure tweet made no mention of safety culture, organizational values, or alignment priorities — it cited personal project goals and characterized the parting as undramatic [3][16]. The contrast between the two departures — one a safety-culture protest, one a career pivot — is consistent with the broader pattern: Karpathy's engagement with OpenAI was oriented around capabilities and education, not safety advocacy.

**Confidence: HIGH | Depth: HIGH**

---

#### Scope of the Relationship and Limits of the Record

The absence of documented engagement between Karpathy and the formal AI safety community is not the same as documented opposition. Karpathy has not publicly criticized the alignment research program, MIRI, the EA-adjacent safety community, or the extinction-risk framing. His public statements distinguish him by omission — empirical focus on concrete failure modes, no named engagement with safety researchers, no signed statements — rather than by any documented rejection of that community's framing.

No indexed source documents Karpathy exchanging ideas with Paul Christiano, Stuart Russell, Eliezer Yudkowsky, or any researcher primarily associated with MIRI or the Alignment Forum. Karpathy has no posts on LessWrong or the Alignment Forum. No shared panels, joint interviews, or documented Twitter interactions with safety-community figures have been found across the period covered by this research (2012–March 2026).

**Confidence: HIGH | Depth: HIGH**

**Uncertainty:** The limits here are those of indexed public record. OpenAI's internal research discussions — spanning two stints that overlap precisely with the most productive period of OpenAI safety research — are not publicly documented. Whether Karpathy engaged informally with safety researchers during those periods, whether he read and commented on alignment papers in internal forums, or whether his apparent non-engagement reflects deliberate choice or simply different research focus cannot be determined from the public record.

---
