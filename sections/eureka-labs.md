## Eureka Labs

**Confidence: HIGH | Depth: MEDIUM**

Karpathy announced Eureka Labs on July 16, 2024 via a detailed post on X/Twitter [26], describing it as "a new kind of school that is AI native." The company name derives from the ancient Greek "I have found it," chosen to reflect the discovery moment when a concept crystallizes for a learner [26][28]. No co-founders or investors have been publicly disclosed; the venture appears to be a solo founding [26][27].

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

The nanochat README itself contains no explicit reference to Eureka Labs or LLM101n [30]. However, Karpathy's announcement tweet thread explicitly resolves the question: "My goal is to get the full 'strong baseline' stack into one cohesive, minimal, readable, hackable, maximally forkable repo. nanochat will be the capstone project of LLM101n (which is still being developed)." [77] The formal curricular relationship is thus confirmed in Karpathy's own words — nanochat is not merely a thematically aligned personal project but is explicitly designated as the hands-on culminating project for the LLM101n course. It also sits on Karpathy's personal GitHub account (not an official Eureka Labs repository), and the tweet characterizes it as simultaneously having "potential to grow into a research harness, or a benchmark, similar to nanoGPT before it" — signalling dual purpose as both course capstone and open research tool [77].

### Execution Status Summary

**Confidence: HIGH | Depth: MEDIUM**

As of March 2026 — approximately 20 months after founding — Eureka Labs has not shipped any commercial product or completed course. The Eureka Labs website continues to describe the platform in aspirational terms and states the team is "heads down building LLM101n" [27]. No beta enrollment, no paying students, no announced partnerships, and no investor disclosures have appeared in any public record [27][29]. The sole concrete publicly released output formally linked to the LLM101n curriculum is nanochat (October 2025): Karpathy explicitly designated it as the course capstone in his announcement tweet [77], though it resides on his personal GitHub account rather than an official Eureka Labs repository [30][77].

### Personal Motivation

Karpathy described Eureka Labs as "the culmination of my passion in both AI and education over ~2 decades" and noted that all his prior educational work — cs231n, micrograd, nanoGPT, Zero to Hero — had been "part-time, as side quests to my 'real job.'" Eureka Labs represents his first professional full-time commitment to the combination [26]. In October 2025 he released **nanochat**, a minimal end-to-end LLM training and inference pipeline, and explicitly designated it as the capstone project for LLM101n in his announcement tweet: "nanochat will be the capstone project of LLM101n (which is still being developed)" [77].

> Note: The July 2024 founding date is confirmed by two Tier 1 sources (Karpathy's announcement tweet [26] and the Eureka Labs website [27]). This resolves the date conflict flagged in Open Questions — the "Eureka Labs 2023" reference in the task issue was incorrect.
