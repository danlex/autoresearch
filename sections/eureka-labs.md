## Eureka Labs

**Confidence: HIGH | Depth: MEDIUM**

Karpathy announced Eureka Labs on July 16, 2024 via a detailed post on X/Twitter [26], describing it as "a new kind of school that is AI native." The company name derives from the ancient Greek "I have found it," chosen to reflect the discovery moment when a concept crystallizes for a learner [26][28]. No co-founders or investors have been publicly disclosed; the venture appears to be a solo founding [26][27].

### The Pedagogical Model

The core operating principle is what Karpathy calls **"Teacher + AI symbiosis"**: a human expert designs high-quality course materials, and an AI Teaching Assistant is layered on top to guide students through them [26][27]. The AI assistant does not replace the instructor's curriculum design role — rather, it scales the instructor's reach. Karpathy's founding vision articulates the problem directly: "subject matter experts who are deeply passionate, great at teaching, infinitely patient and fluent in all of the world's languages are also very scarce and cannot personally tutor all 8 billion of us on demand." [26] With generative AI progress, the ideal of having a Feynman-like tutor for every learner — "who is there to guide you every step of the way" — becomes tractable [26][27].

The intended outcome is to expand education in two dimensions simultaneously: in **reach** (many more people accessing instruction) and in **extent** (any one person learning more subjects than would be possible today, unassisted) [27][28].

Human instructor responsibilities: design the curriculum, author course materials, provide the pedagogical structure. AI assistant responsibilities: delivery and guidance — answering questions, providing patient on-demand support in any language, helping students through the instructor-designed materials at their own pace [26][27].

**Uncertainty:** As of March 2026, no working interactive AI tutor product has been publicly demonstrated. The Eureka Labs website describes the model in aspirational terms; the specific interaction modality (chat interface, embedded exercises, etc.) has not been publicly detailed [27].

### AI Tutor Design: Elaborations from the Dwarkesh Patel Interview (October 2025)

**Confidence: MEDIUM | Depth: MEDIUM**

The October 17, 2025 Dwarkesh Patel podcast interview ("AGI is still a decade away") is the most detailed primary-source elaboration of Karpathy's pedagogical thinking and AI tutor design goals [17]. The full transcript was partially accessible; the following findings are drawn from [17] and cross-checked against multiple secondary summaries [78][79].

**The Korean tutor experience as the design target.** Karpathy describes learning Korean from a one-on-one human tutor as his foundational reference point for what an AI teaching assistant must eventually achieve: "I felt like I was the only constraint to learning... I was always given the perfect information." He contrasts this with larger classes and self-directed online learning, both of which he found substantially inferior. The key capability he identified: a skilled human tutor instantly assesses the student's current knowledge level and asks precisely calibrated diagnostic questions — probing the student's "world model" to find and fill gaps. He was explicit that no current LLM comes close to replicating this capability [17][78][79].

**Honest assessment of current AI tutoring.** Karpathy does not overstate the present state of AI tutoring. He described current LLM tutoring as producing "slop" relative to the aspiration — "already super valuable" in the sense that asking an LLM questions is genuinely useful, but categorically falling short of genuine personalized instruction. The diagnostic sophistication and adaptive responsiveness of a skilled human tutor is not yet present [17][78]. He framed it explicitly: Eureka Labs is not yet in the phase of building the "ultimate AI tutor" — that is a capability milestone the field has not reached. LLM101n is the test case for learning how that assistant should be designed [17][78][79].

**"Pre-AGI education is useful. Post-AGI education is fun."** Karpathy introduced a temporal framework for thinking about educational purpose in the interview. He drew an analogy to gymnasium attendance: physical fitness is no longer economically necessary (machines handle physical labor) but people pursue it for health and psychological fulfillment. He projects that education will undergo the same transition — shifting from economically instrumental (learning to get a job) to intrinsically rewarding (learning for cognitive flourishing). He referenced historical precedent: wealthy individuals and ancient Greeks pursued intellectual development when freed from labor requirements. His concern is the *WALL-E*/*Idiocracy* failure mode where humans are disempowered and intellectually atrophied rather than liberated and enriched [17][78].

**"Starfleet Academy" as the long-horizon vision.** Karpathy described the long-term ambition for Eureka Labs as building "Starfleet Academy" — a modern elite institution focused on frontier technical knowledge, where faculty work alongside AI to develop and deliver state-of-the-art courses. AI eventually handles routine TA duties (answering student questions from course materials) while human faculty concentrate on curriculum design and intellectual leadership. He noted his primary concern is that humanity will be "disempowered and sidelined" by AI — Eureka Labs is framed as an active counter-strategy [17][78][79].

**Pedagogical principles — "pain before solution" and "eurekas per second."** Karpathy articulated two design principles for learning materials. First, the "pain before solution" approach: present the limitation of a simpler method first, then introduce the more complex solution as the fix for a specific, experienced problem. His LLM101n syllabus is organized around this principle — beginning with a bigram lookup table and progressively introducing each architectural component (attention, transformers, tokenization) as the answer to a problem the student has already felt [17][78][79]. Second, he described "eurekas per second" as his design metric for course materials: the goal is to maximize the rate of genuine insight — each minute of engagement should produce real crystallization of understanding rather than passive information transfer [17][78].

**Technical instruction approach.** For nanochat (the LLM101n capstone), Karpathy recommends a specific learning mode: put the code on one monitor and attempt to reconstruct it from scratch on the other, without copy-pasting. He noted that even assembling nanochat himself, current LLMs were of limited help — the code is "intellectually intense" and models would misfire because they had too much "memory from typical ways of doing things on the Internet," defaulting to common but suboptimal patterns rather than the minimal, first-principles design he was targeting [17][79].

### LLM101n — The First Course

The only course publicly announced is **LLM101n: "Let's build a Storyteller"** [26][29]. It is described as an undergraduate-level class that guides students through training their own AI language model — "a smaller version of the AI teaching assistant itself" — building a ChatGPT-like web application from scratch using Python, C, and CUDA [27][29].

The 17-chapter syllabus progresses from first principles to production: bigram language models, backpropagation (building on Karpathy's earlier micrograd), n-gram architectures, attention mechanisms, transformers, tokenization, initialization, AdamW optimization, distributed training, mixed precision, quantization, dataset curation, kv-cache inference, supervised fine-tuning, reinforcement learning, deployment, and multimodal capabilities (VQVAE, diffusion transformers) [29]. The organizing principle — "What I cannot create, I do not understand" — is a direct continuation of the first-principles construction approach that defines all of Karpathy's educational work [29].

Delivery is planned in three formats: online self-paced materials, digital cohorts, and physical cohorts [27]. Course materials are distributed via GitHub (github.com/karpathy/LLM101n). The repository was archived on August 1, 2024 — two weeks after the founding announcement — with an explicit README notice: "this course does not yet exist. It is currently being developed by Eureka Labs. Until it is ready I am archiving this repo." [29] As of March 2026, the repository contains only the README outline and a header image: no instructional content, exercises, or lecture materials have been published. No specific completion timeline has been stated [27][29].

### nanochat — The Closest Shipped Artifact

**Confidence: HIGH | Depth: MEDIUM**

On October 13, 2025, Karpathy released **nanochat** as an open-source project on GitHub (github.com/karpathy/nanochat) [30]. The project is described as "the simplest experimental harness for training LLMs" — covering the complete pipeline from tokenization and pretraining through fine-tuning, evaluation, inference, and a chat interface, all on a single GPU node [30]. Its accessibility framing is explicit: a GPT-2-capable model can be trained for approximately $48 in around two hours on an 8×H100 node, compared to the ~$43,000 cost of GPT-2 training in 2019 [30].

Architecturally, nanochat uses a single complexity parameter (`--depth`, controlling transformer layer count) that automatically derives all other hyperparameters — model width, learning rate, and training schedule. GPT-2-equivalent capability appears at depth 24–26 [30]. The project maintains a public "Time-to-GPT-2 Leaderboard" tracking wall-clock training time against the DCLM CORE benchmark [30]. Active development was ongoing as of the October 2025 release; commit history as of March 2026 reflects continued updates. [UNVERIFIED — March 2026 activity observation requires direct repository inspection; not supported by [30] alone.]

The nanochat README itself contains no explicit reference to Eureka Labs or LLM101n [30]. However, Karpathy's announcement tweet thread explicitly resolves the question: "My goal is to get the full 'strong baseline' stack into one cohesive, minimal, readable, hackable, maximally forkable repo. nanochat will be the capstone project of LLM101n (which is still being developed)." [77] The formal curricular relationship is thus confirmed in Karpathy's own words — nanochat is not merely a thematically aligned personal project but is explicitly designated as the hands-on culminating project for the LLM101n course. It also sits on Karpathy's personal GitHub account (not an official Eureka Labs repository), and the tweet characterizes it as simultaneously having "potential to grow into a research harness, or a benchmark, similar to nanoGPT before it" — signalling dual purpose as both course capstone and open research tool [77].

### Execution Status Summary

**Confidence: HIGH | Depth: MEDIUM**

As of March 2026 — approximately 20 months after founding — Eureka Labs has not shipped any commercial product or completed course. The Eureka Labs website continues to describe the platform in aspirational terms and states the team is "heads down building LLM101n" [27]. No beta enrollment, no paying students, no announced partnerships, and no investor disclosures have appeared in any public record [27][29]. The sole concrete publicly released output formally linked to the LLM101n curriculum is nanochat (October 2025): Karpathy explicitly designated it as the course capstone in his announcement tweet [77], though it resides on his personal GitHub account rather than an official Eureka Labs repository [30][77].

### Corporate and Funding Structure

**Confidence: MEDIUM | Depth: MEDIUM**

Eureka Labs was incorporated as a **Delaware LLC on June 21, 2024** — approximately three weeks before Karpathy's public founding announcement on July 16, 2024 [26][71]. The California Secretary of State foreign LLC filing is signed solely by Karpathy; no other officers, directors, or agents appear in any publicly available filing [71]. The entity type (LLC) and sole-signatory filing are consistent with the founding framing of a solo venture: no co-founders have been named in any primary or press source [26][27][28].

**No external funding has been publicly disclosed.** A search of SEC EDGAR for Eureka Labs (which would capture any Form D Regulation D exempt offering) returned no results [80]. Crunchbase and PitchBook profiles for Eureka Labs exist but are paywalled and list no funding rounds in any secondary reporting [81]. No venture capital firms, angel investors, or strategic backers have been named in any press coverage or public record as of March 2026 [28][71].

**Uncertainty:** The absence of a public funding announcement does not confirm self-funding — early-stage rounds are sometimes raised under confidentiality before a product ships. Given Karpathy's compensation history at Tesla and OpenAI, bootstrapping is plausible, but no authoritative source has confirmed this. The AIExpert Network article ([71]) notes explicitly: "it is unclear whether Eureka Labs is self-funded or has secured external investment. There are no public filings of any investments related to the startup." The Eureka Labs website itself contains no investor disclosures, no team page beyond implicit reference to Karpathy, and no legal entity information [27].

**Regarding source [71]:** The AIExpert Network article on Eureka Labs is the primary source documenting the Delaware LLC formation date of June 21, 2024, and the California Secretary of State filing signed solely by Karpathy. It is a Tier 3 source (independent analysis blog). Delaware ICIS and OpenCorporates could not be accessed programmatically (CAPTCHA-gated) to obtain the raw filing record directly.

### Personal Motivation

Karpathy described Eureka Labs as "the culmination of my passion in both AI and education over ~2 decades" and noted that all his prior educational work — cs231n, micrograd, nanoGPT, Zero to Hero — had been "part-time, as side quests to my 'real job.'" Eureka Labs represents his first professional full-time commitment to the combination [26]. In October 2025 he released **nanochat**, a minimal end-to-end LLM training and inference pipeline, and explicitly designated it as the capstone project for LLM101n in his announcement tweet: "nanochat will be the capstone project of LLM101n (which is still being developed)" [77].

> Note: The July 2024 founding date is confirmed by two Tier 1 sources (Karpathy's announcement tweet [26] and the Eureka Labs website [27]). This resolves the date conflict flagged in Open Questions — the "Eureka Labs 2023" reference in the task issue was incorrect.
