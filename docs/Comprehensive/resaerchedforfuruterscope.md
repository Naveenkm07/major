# KrushikaDhara: An AI-Powered Multilingual Precision Agriculture Platform

**Ms. Lavanya C . Naveen Kumar KM1, G. Mohnish2, Chandrashekhar3, Arun Viraktamath4**
Department of Computer Science and Engineering New Horizon College of Engineering Affiliated to 
Visvesvaraya Technological University (VTU) Bengaluru, India
¹1nh24cs409@newhorizonindia.edu ²1nh23cs060@newhorizonindia.edu
³1nh23cs080@newhorizonindia.edu ⁴1nh23cs029@newhorizonindia.edu

**Abstract** — Agriculture is the mainstay for over 600m 
Indians [1], but farmers rearing crops on the smallest 
landholdings, typically less than two hectares, still find 
it difficult to get reliable crop health advice, fair prices 
in the market, timely information on government 
subsidies and access to formal loans. Most of the digital 
tools built for them never work in practice: they require 
continuous internet, are in English only or rely on 
expensive cloud services which don’t make much 
sense in the villages of rural Karnataka where network 
coverage is patchy and linguistic diversity is the norm. 
That’s why we created KrushikaDhara . This is a cross-platform mobile application (Flutter, with Java 
backend) running on free open-source infrastructure 
entirely. It combines eight tightly coupled modules. 
The detection of disease and pest is done using 
tensorflow lite model with YOLO based object 
detection without server round trip. The Agmarknet 
portal sends Firebase Cloud Messaging notifications to 
farmers on live wholesale-market rates. Generates crop 
calendar based on location using Open-Meteo weather
feeds and Groq-hosted Llama 3 inference to provide 
sowing and harvest advice. So we built a Retrieval-Augmented Generation pipeline to explore government 
welfare programs: The policy PDFs specific to 
Karnataka are chunked, embedded and indexed in 
ChromaDB, enabling the system to surface relevant 
schemes in response to a farmer’s plain-language 
question. Another pest-risk module correlates hyper-local weather patterns with ESA Sentinel-2 satellite 
imagery to signal outbreaks before they spread. The 
platform also offers a peer network for farmers in close 
proximity to share equipment and pool labour, an 
advisory engine for Kisan Credit Card and institutional 
loan applications and – crucially for adoption – a fully 
Kannada voice interface powered by the Bhashini API, 
so literacy is never a barrier. 
In controlled tests, the disease detector managed 91.2% 
accuracy, scheme retrieval 94.3% precision and 
market-price alerts came in under four seconds – all 
without any paid infrastructure. The entire stack is 
open-source and designed so that other states or other 
crops can plug into the same architecture with little 
rework.

**Index Terms** — Edge AI, Precision Agriculture, 
Retrieval-Augmented Generation (RAG), TensorFlow 
Lite, Flutter, Vernacular NLP, Agmarknet, Karnataka, 
Bhashini, Groq Llama 3.

## I. INTRODUCTION
Agriculture is still a big part of India's economy, 
making up around 17.8% of the country's GDP as of 
2023-2024. It's also the main job for more than 42% of 
the workforce. In Karnataka, there are over five million 
farming households working in different areas with 
unique climates. For example, in the dry central part of 
the state, farmers mostly grow Ragi and Groundnut. In 
the Western Ghats' Malnad region, Coffee and 
Arecanut are the main crops. Meanwhile, in the 
northern districts around Dharwad and Bijapur, Onion 
and Pomegranate are the most common crops. 
This diversity is great to see, but it also means that one 
digital tool cannot be used everywhere, what works in 
one place does not work in another. 

When I speak to farmers from all over the country, 
there are always three big concerns that come up. The 
problems are also pointed out in many research papers 
and studies. Firstly, farmers are losing large amounts 
of crops. According to the FAO and CABI, around 
40% of the world’s crops are lost each year to pests and 
diseases.

The problem is as prevalent in the local areas as it is in 
Karnataka. Many farmers try to solve the issue only 
after the damage is visible. For example, most farmers 
in Karnataka tend to respond to the problem after they 
can see the damage rather than proactively preventing 
it. The second problem is that the farmers are not 
getting a fair price for their produce. This can be 
devastating to their livelihoods. To make matters 
worse, many farmers do not have access to reliable 
markets and are often taken advantage of by 
middlemen who take a large portion of their profits. As 
a result, farmers are finding it difficult to make ends 
meet and their ability to As a result, farmers are 
struggling to make ends meet, and their ability to invest 
in their farms and communities is severely limited.

For instance, a farmer in a village in Kolar may be 
selling his tomatoes at Rs 8-10 per kg, but at the same 
time, the price at the Yeshwanthpur APMC, just 70 km 
away, is Rs 12-14 per kg. The farmer loses 20% to 30% 
of the price potential simply because he didn’t know 
about the better price somewhere. The third problem is 
that a lot of farmers are not aware of the schemes and 
subsidies that they are eligible for. Research has shown 
that more than 60% of eligible farmers have never 
heard of these schemes as information is usually 
available on complex websites in English or formal 
Hindi. This makes it difficult for farmers to receive the 
assistance they need.

“It is hard for farmers in the countryside to get good 
advice on their phones. Some platforms like Kisan 
Suvidha, AgroStar, DeHaat are trying to help but they 
have some big problems. For example, the Kisan 
Suvidha app is available only in English and requires a 
good internet connection. That’s a problem for many 
farmers who don’t speak English well or have slow 
internet. The AgroStar advice system was not trained 
to diagnose diseases like Ragi blight or Arecanut 
yellow-leaf disease, both common to Karnataka. 
DeHaat’s system works well in some parts of the 
country but does not cover many areas in southern 
Karnataka.

And the worst part is that none of these platforms work 
without internet which is a big problem especially in 
rural areas where internet connection is often slow or 
non-existent. So, the farmers who need advice the most 
can't get it when they need it.

KrushikaDhara, which translates to “Stream of 
Farming” in Kannada (Kannada: ಕೃ#ಕ$ಾರ), was 
developed to address the real challenges faced by 
farmers rather than attempting to work around them.
It’s a mobile app built with Flutter, with a Java 
backend, and it’s using open source tools and free 
government APIs. The app has some very useful 
features like an artificial intelligence-based disease 
detection system, a way to find schemes and programs 
that farmers can access and weather and satellite 
updates that warn about pest risks.It even has a voice 
interface in Kannada using the Bhashini API, so 
farmers who can’t read, can ask questions and get 
answers that they can understand. This way farmers 
can get the help they need even if they are not tech 
savvy. The app provides them with a constant stream 
of information and support, always available to help 
them with their farming needs

The remainder of this paper is organized as follows. 
We begin with Section II, a review of related work. 
Then in section III we present the setup of our system. 
Section IV then takes us through the design of each 
part of the system. Finally, section V is dedicated to 
the actual construction. Section VI presents the results 
of our experiments. Finally, in Sections VII to X we 
talk about the good things about our system, how it 
can be used in real life, what we might do next, and 
what we learned from all of this.

## II. LITERATURE REVIEW
### A. Computer Vision for Crop Disease Detection
The PlantVillage experiment by Mohanty et al is still 
frequently cited in the context of deep learning based 
disease diagnosis in plants at the leaf level. The 
interesting thing here is that their convolutional neural 
network or CNN could reach an accuracy of 99.35% 
when tested on the PlantVillage dataset – a collection 
of images taken in a lab with a white background and 
consistent lighting. When the same model was applied 
to field photos taken with phone cameras, however, the 
accuracy decreased to about 31%. This large difference 
between results from a controlled laboratory 
environment and real world application has had a 
major influence on the course of subsequent research 
in this area. It discusses the difficulties of turning 
encouraging laboratory results into workable solutions 
that can stand up to the vagaries of the real world. 

To fill the gap, Ferentinos tested several architectures 
(AlexNet, GoogLeNet and VGGNet) against a large set 
of 87,848 leaf images covering 58 different crop-disease pairs. The best model achieved a very high 
accuracy of 99.53%. But it still required uploading the 
image to a server to do the analysis, and there was no 
way to run the classifier on the user’s device. This 
limitation rendered the system less convenient and less 
efficient than it could have been. But for instance, 
Kamilaris and Prenafeta-Boldú [3] examined 40 
studies, which were all focused on using deep learning 
methods for various agricultural tasks, including 
disease detection, weed mapping, and fruit counting, 
and found the same thing: Most researchers seek to 
achieve the highest accuracy on their curated 
benchmarks and forget to consider the constraints of 
deployment, such as model size, latency, and 
availability offline on a ₹8,000 Android phone. This is 
taken care of directly by the quantization framework 
proposed by Jacob et al. [4] which demonstrates that 
weights can be quantized from 32-bit floating point to 
8-bit integers with minimal classification accuracy 
loss, thereby enabling real-time on-device inference 
using TensorFlow Lite.

KrushikaDhara relies on this trend— high-accuracy 
architectures from [1][2], deployment awareness from 
[3], and the quantization toolkit from [4] - to create a 
disease-detection module that runs fully on the farmer's 
phone without any network call.

### B. Agricultural Market Intelligence Systems
Surabhi Mittal’s research in agriculture highlights an 
important insight: when farmers gain access to timely 
and reliable market price information, they often 
experience a 15–25% increase in net income. This 
improvement is largely driven by better negotiation 
power, as farmers become aware of competitive 
pricing across nearby mandis.

However, Mittal also observed that these benefits are 
not distributed equally. Farmers who are better 
connected and have access to mobile phones and 
internet services benefit the most, while poorer 
households may still be excluded due to the lack of 
smartphones, data connectivity, or digital literacy.

The e-NAM portal of the Government of India was 
intended to address this issue on a large scale and 
establish a single electronic trading platform across all 
regulated “Mandis”. In practice, adoption has been 
cumbersome. Field observations indicate that many 
smallholders are having difficulty understanding the 
registration procedures, that the application assumes a 
high level of English or Hindi fluency, and that 
information is provided about auctions hours after the 
fact, meaning information becomes of little use [6]. At 
the same time, Fafchams and Minten [7] conducted a 
randomized controlled field experiment with Reuters 
Market Light's SMS price alerts in Maharashtra, the 
result being surprising: Some of the farmers did go to 
the higher prices markets, but the resulting "increase in 
the average price received was not significant. 
Prediction signals on prices, along with some logistics, 
are also necessary components to inform farmers' 
decisions based on raw price data, according to the 
implication.

The issue is resolved using KrushikaDhara's module, 
called 'Mandi'. This module fetches the wholesale price 
in real-time from Agmarknet. But that's not all - it also 
sends alerts to Firebase Cloud Messaging when the 
price change is more than a certain value set by the 
user. Plus, it includes a simple trend indicator that helps 
farmers decide whether to sell or not.

### C. Retrieval-Augmented Generation in Specialized Domains
The RAG framework was proposed by Lewis et al. [7] 
at NeurIPS 2020 that combines a dense-vector retriever 
(faiss-based Wikipedia) and a BART sequence-to-sequence generator. The big news wasn’t just the 
improved accuracy on open-domain QA benchmarks 
— it was that the knowledge base could be changed out 
or updated without retraining the generator, which is 
exactly the property you want when the underlying 
documents are government policy PDFs that change 
every budget cycle. 

There is still significant scope for the application of 
Retrieval-Augmented Generation (RAG) in 
agriculture. Recent studies on agricultural question-answering systems grounded in ICAR Package-of-Practices documents have demonstrated that retrieval-augmented pipelines consistently outperform fine-tuned baseline models. One such study reported an 
improvement in F1-score from 0.62 to 0.87, primarily 
because the retriever effectively handles domain-specific terminology that general-purpose large 
language models (LLMs) may otherwise hallucinate 
or misinterpret.

KrushikaDhara’s scheme discovery module follows a 
similar approach, but focuses specifically on 
Karnataka-related agricultural policy documents. 
Instead of using FAISS, the system indexes these 
PDFs using ChromaDB, prioritizing simpler self-hosting and maintainability over maximum retrieval 
speed.

### D. Pest-Weather Correlation and Precision Warnings
Since Stephens’ formalisation in the 1950s [9], plant 
pathologists have relied on the Disease Triangle, the 
interaction between a susceptible host, a virulent 
pathogen and a conducive environment. The insight is 
straightforward: if it’s possible to keep track of the 
environmental leg of the triangle in near-real-time, 
then it’s possible to predict outbreaks before symptoms 
appear. Computational models which operationalise 
this idea for Indian crop-pathogen pairs [10] have 
shown that 48-hour advance warnings can reduce 
fungicide sprays by a third, saving both money and soil 
health. 

The catch is granularity of data. The district-level 
weather averages, the resolution most government 
APIs provide, smooth over the micro-climatic variation 
that actually drives fungal spore germination on a two-hectare plot. Lobell’s group at Stanford [11] 
demonstrated moving to field-level or hyper-local 
weather inputs strongly upgrades yield-prediction 
models for smallholder farms, and the same logic 
applies to pest-risk forecasts. This is why the 
KrushikaDhara pest module uses hourly, GPS-pinned 
weather from Open-Meteo and cross-references it 
against ESA Sentinel-2 vegetation indices to provide a 
risk score for each farmer based on their actual plot, 
and not their district headquarters. 

### E. Research Gaps
The threads above – on-device disease detection, real-time Mandi intelligence, RAG-based scheme retrieval, 
hyper-local pest-weather correlation – have each been 
explored independently, often with promising results. 
What is missing is a single mobile platform that 
stitches them together and actually runs in the field 
conditions of rural Karnataka: offline-capable, 
Kannada-first, and built entirely on free infrastructure. 
KrushikaDhara is our effort to fill that gap. 

## III. SYSTEM DESIGN AND METHODOLOGY
### A. System Overview
KrushikaDhara utilizes a hybrid edge-cloud 
architecture as shown in Fig. 1. The split is based on a 
simple rule: everything a farmer might need when 
standing in a field with no signal runs on the phone 
itself. On the device, models and lookup tables 
packaged inside the APK perform disease detection, 
EMI estimation, and a first-pass scheme eligibility 
check. The live data dependent features like wholesale 
Mandi prices, crop calendar advice generated by 
LLMs, hourly weather feeds and push notifications are 
powered by a lightweight Java backend server. When 
the phone is offline, those cloud features gracefully fall 
back to the last cached response, not an error screen.
When a connection is restored, the app marks the data 
as stale and refreshes silently.

Fig. 1. KrushikaDhara Hybrid Edge-Cloud Architecture of the 
System. Green: on-device modules (works offline) Blue: Java 
Microservices. Gray: external APIs and data sources.

### B. Disease and Pest Detection Module
The detection pipeline runs entirely inside the Flutter 
app. We then quantize this model to INT8 and ship it 
as a .tflite asset that has been transfer-learned on the 
PlantVillage dataset and further augmented with 
~4,000 field-collected Karnataka leaf images (Ragi 
blast, Arecanut yellow-leaf, Groundnut tikka). When a 
farmer opens the camera, the frame captured is resized 
to 416 × 416 pixels, normalised to a range of [0, 1] and 
passed to the TFLite interpreter. The model predicts 
bounding boxes and class probabilities across 38 
disease classes. Inference takes ~180 ms on a mid-range handset (Snapdragon 665, 4 GB RAM) – fast 
enough to feel instantaneous. No data is sent off the 
phone. Once a disease is identified, the app then 
searches a local JSON table that maps each condition 
to one or more chemical treatments, including dosage 
per acre, safety interval and, where possible, an organic 
alternative. The table was compiled based on UAS 
Bangalore Package of Practices and reviewed by two 
agricultural-extension officers. 

### C. Mandi Price Intelligence and Alert Engine
A Spring Boot scheduled job (@Scheduled(cron = 
"0 0 6 * * *")) runs at 06:00 IST daily and hits the 
data.gov.in Agmarknet REST endpoint pulling the 
wholesale rates of the previous day for every 
commodity–district pair in Karnataka. The raw JSON 
is cleaned (duplicate entries and rows with null price 
are removed), normalised and written to a Firebase 
Realtime Database node keyed by 
/{commodity}/{district}/{date}. 

A comparison routine then walks the new entries 
against the snapshot from yesterday. For every pair 
whose price has changed by more than a configurable 
threshold (default: ±10%) the backend creates a 
personalised Firebase Cloud Messaging payload and 
pushes it to every farmer who has registered an interest 
in that commodity. One such alert reads: “Tomato in 
Kolar APMC up 14% overnight – ₹12.40/kg v/s ₹10.85 
yesterday. 

If the Agmarknet API returns an HTTP error or times 
out, a Jsoup-based scraper automatically kicks in and 
parses the same data from the Agmarknet HTML tables 
as a fallback. “You never know the difference.” 

### D. Dynamic Crop Calendar
The calendar is a mix of two knowledge sources. 
The first is a set of JSON rule files encoding the UAS 
Bangalore Package of Practices – sowing windows, 
expected maturity periods and recommended inputs –
for each crop-agro-climatic-zone pair in Karnataka. 
The second is a live 15-day weather forecast from the 
Open-Meteo API for the farmer’s exact GPS 
coordinates. Hourly temperature, relative humidity, 
cumulative probability of rainfall, and estimated soil 
moisture at 0-10 cm depth. 

When a farmer asks for a calendar, the backend 
merges the relevant rule file with the weather payload 
and sends both as structured context to Groq’s hosted 
Llama 3 8B model. The prompt is intentionally limited: 
it instructs the model to respond in Kannada, to use 
ONLY the data provided, and to output a week-by-week action plan instead of a generic paragraph. 
Because the inference runs on Groq’s free tier, the 
round-trip (including network latency) averages under 
2 seconds. 

### E. Government Scheme RAG Pipeline
Karnataka has dozens of overlapping agricultural 
welfare programmes – Raitha Sanjeevini, Krishi 
Bhagya, Ganga Kalyana, PM KUSUM, and a rotating 
set of NABARD refinance circulars, among others. 
Official PDFs outlining eligibility, application steps 
and subsidy amounts are scattered across multiple state 
portals and updated with no notice. There is no way 
that any farmer (or, frankly, any extension officer) can 
keep track of all of them. 

We do this with a standard RAG pipeline, adapted to 
the domain. All PDF files are first processed through 
Apache Tika to handle the inconsistent formatting and 
scanned-page OCR that is common in government 
documents. The extracted text is then chunked into
512-token chunks with a 50-token overlap to preserve 
context across chunk boundaries – a chunking strategy 
we selected after testing 256- and 1024-token 
alternatives and finding 512 to yield the best retrieval 
precision on our validation set of 120 farmer queries. 
Each chunk is embedded with the all-MiniLM-L6-v2 
sentence transformer (384 dimensions, fast enough to 
re-index the full corpus in under 90 seconds on a single 
CPU!) and stored in a ChromaDB collection. 

When a farmer asks a question (either by typing or 
through the voice pipeline described in Section G) the 
question is embedded with the same model and the five 
most similar chunks are retrieved by cosine distance. 
The original question and these chunks are fed into 
Groq-hosted Llama 3 8B in a very tightly constrained 
prompt; the model is instructed to answer only based 
on the retrieved text and to say “I don't have 
information on this” if no chunk is relevant. This 
eliminates the hallucination of nonexistent schemes – a 
failure mode we observed in every unconstrained LLM 
we tested during development. 

### F. Pest-Weather Correlation Engine
Each registered farmer has their GPS coordinates 
(taken once during onboarding) stored in the backend. 
A cron job pings the Open-Meteo API every 6 hours to 
get 48-hour forecasts of temperature, relative humidity 
and precipitation probability for that exact location. In 
parallel, the system ingests ESA Sentinel-2 
multispectral satellite passes (10 m resolution, revisit 
cycle of ~5 days) and derives a Normalised Difference 
Vegetation Index (NDVI) and a soil-moisture proxy 
from the short-wave infrared bands. 

These readings are then compared to known pathogen-activation windows using a rule-based threshold 
engine. For example, Xanthomonas axonopodis pv. 
punicae causing pomegranate oily-spot disease which 
is a major concern of Vijayapura and Bagalkot districts 
of Karnataka is active when the temperature ranges 
from 25 °C to 33 °C and relative humidity is more than 
60% for more than 12 consecutive hours [ref: ICAR-NRC Pomegranate]. If the forecast indicates such 
convergence in the next 48 hours, the system sends a
preventive-treatment alert via FCM, indicating the 
specific pathogen, the recommended bactericide 
(Streptocycline at 0.5 g/L + COC at 2.5 g/L), and the 
spray window. 

Rules are saved in editable JSON configs, so adding a 
new crop-pathogen pair does not require code changes, 
just a new JSON entry containing the activation 
thresholds and treatment mapping. 

### G. Voice-First Kannada Pipeline
Literacy is not a given. More than 30% of the farming 
population of Karnataka is not educated beyond the 
secondary school level. Many of the older farmers are 
more comfortable speaking than reading, even 
Kannada script. The voice pipeline is not a 
convenience feature, it is an access layer.

When a farmer taps the microphone icon, Flutter’s 
audio-capture API records a WAV stream and sends it 
to the Bhashini ASR endpoint. Bhashini leverages 
IndicWhisper-family models fine-tuned on Indian 
dialect speech, and outputs a Kannada-text transcript. 
Then an intent classifier (a light-weight logistic-regression model trained on ~2,000 labelled Kannada 
utterances) routes the transcript to the correct backend 
module: disease queries to the detection pipeline, 
scheme questions to the RAG engine, price queries to 
the Mandi module, and so on. 

The selected module generates an answer in English 
(as Llama 3 yields better results in English). Bhashini's 
NMT API translates this response into Kannada and 
Bhashini's neural TTS endpoint synthesizes this into 
speech, a FastPitch + HiFi-GAN architecture that 
outputs natural sounding Kannada audio. The farmer 
gets a verbal response to his question within three or 
four seconds without having to read or type a single 
character. 

## IV. SYSTEM ARCHITECTURE
### A. Module Interaction and Offline Strategy
The eight modules discussed in Section III are 
intentionally loosely coupled, exposing only a single 
REST endpoint on the Java backend and able to be 
developed, updated, or taken offline independently of 
the others. This is important as governments APIs can 
go down without warning in practice (the Agmarknet 
endpoint was down for 11 hours during our testing in 
March 2026) and the rest of the platform should keep 
working even if one data source fails. 

The client side Flutter app maintains a local 
SQLite database with the farmer profile, registered plot 
coordinates, crop history and results of the last scheme-eligibility query. Any module that can run against 
cached data – disease detection (fully offline), EMI 
calculation and scheme pre-screening, does so without 
the need to check for a network connection. Connected 
modules (Mandi alerts, crop calendar, pest-weather 
engine) attempt to make a live call, if they fail, they 
display the last cached result with a timestamp badge 
so that the farmer knows how old the data is. 

Table I associates each module with the main 
technology stack, connectivity requirement and output 
format . 

**TABLE I**
**Module-Level Technology Mapping**

| Module | Primary Technology | Connectivity | Output |
| --- | --- | --- | --- |
| Disease Detection | TFLite + YOLOv8 (INT8 Quantized) | Offline | Visual + Text |
| Mandi Price Alert | Agmarknet API + FCM | Online | Push Notification |
| Crop Calendar | Open-Meteo + Groq Llama 3 | Online | Text / Audio |
| Scheme RAG | ChromaDB + Llama 3 | Online | Text / Audio |
| Pest-Weather Engine | Open-Meteo + Sentinel-2 NDVI | Online | Push Notification |
| Farmers Connect | GPS Proximity + Bluetooth Mesh Fallback | Hybrid | In-App Feed |
| Loan Advisory | RAG over DCC Bank / NABARD PDFs | Online | Text / Checklist |
| Voice Pipeline | Bhashini ASR + NMT + TTS | Online | Audio |

### B. Data Flow
Fig. 2 illustrates the two primary data paths through the 
system.
Offline Path (Disease Detection – Most 
Frequently Used Feature)
The farmer opens the camera and captures an image of 
a crop leaf. The complete processing pipeline —
including image preprocessing (resizing to 416 × 416 
and normalization), TensorFlow Lite (TFLite) 
inference, and treatment recommendation lookup — is 
executed entirely on the device in under 200 ms.
The result screen displays the detected disease name, a 
colour-coded severity indicator (green, amber, or red), 
the recommended chemical treatment along with the 
dosage per acre, and, where available, an organic 
alternative. Since all processing is performed locally, 
no data leaves the user’s phone, ensuring privacy and 
offline accessibility.

Online path (all features connected) A user request or 
scheduled cron job hits the Java backend over https. 
The backend makes the relevant external API call 
(Agmarknet for prices, Open-Meteo for weather, Groq 
for LLM inference, Bhashini for speech) and then 
processes the response before either writing it to 
Firebase Realtime Database (for persistent data) or 
pushing it directly to the farmer’s device using FCM 
(for time-sensitive alerts). The Flutter client refreshes 
its local SQLite cache for every successful response. If 
the next request fails, the data is still present.

## V. IMPLEMENTATION DETAILS
### A. Mobile Client (Flutter)
The application is developed using Flutter 3.19 and 
supports Android API 24+ (Android 7.0 Nougat and 
above) as well as iOS 14+. Flutter was chosen over 
native Kotlin or Swift development primarily to 
maintain a single unified codebase across platforms. 
Since the farmer-facing interface mainly consists of 
large buttons, high-contrast colour schemes, and 
readable typography, platform-specific widgets were 
not essential.

The application integrates several key dependencies. 
The camera package (v0.10.5) is used to stream the 
live viewfinder during crop disease image capture. 
The tflite_flutter package (v0.10.4) enables loading 
and execution of the quantized YOLO model directly 
on the device. The geolocator package is used to 
obtain GPS coordinates during farm plot registration. 
The flutter_local_notifications package delivers 
mandi price updates and pest-risk alerts even when 
the application is running in the background. 
Additionally, the speech_to_text package captures 
voice input before forwarding the audio to Bhashini 
for language processing.

The entire user interface is localized in both English 
and Kannada using Flutter’s intl package. Language 
switching takes effect instantly without requiring the 
application to restart.

### B. Backend Server (Java / Spring Boot)
The server-side is written in Java 21 with Spring Boot 
3.2. We chose Spring Boot because the team had 
experience with it and because its annotation-driven 
scheduling (@Scheduled) and non-blocking HTTP 
client (WebClient) made it easy to implement the 
Agmarknet polling loop and external API fan-out. 

The backend has four main responsibilities: (i) daily 
Agmarknet price ingestion via a cron-triggered 
@Scheduled task, (ii) non-blocking REST calls to 
Open-Meteo, Groq and Bhashini through Spring 
WebClient, (iii) PDF ingestion for the RAG knowledge 
base using Apache Tika 2.9 (which handles the 
inconsistent encodings and scanned pages common in 
government PDFs), and (iv) embedding generation and 
vector search over ChromaDB through LangChain4J 
0.29’s langchain4j-chroma module. 

The whole backend is on an Oracle Cloud Always Free 
ARM instance (Ampere A1, configured as 2 OCPUs 
and 12 GB RAM out of the 4-OCPU / 24-GB free-tier 
allotment). At this spec the server is able to handle our 
current test load of ~200 concurrent farmers without 
memory pressure. 

### C. LLM Inference (Groq Cloud)
All calls to large-language-models are performed 
through the Groq Cloud API, with the Meta Llama 3 
8B Instruct model. We chose Groq’s LPU (Language 
Processing Unit) inference hardware since it delivers 
first-token latency of less than 300 ms, which is about 
5x faster than other API providers running the same 
model on GPU. The voice pipeline must feel 
conversational and anything over 500 ms for the first 
token makes it feel sluggish. 

The free tier allows you 30 requests per minute and 
14,400 requests per day which easily supports our 
current user base. All prompts are highly constrained. 
RAG prompts have a system instruction that forbids 
answers that are not based on the retrieved chunks. 
Crop-calendar prompts require the output to be in 
Kannada language and in weekly structure. Scheme-eligibility prompts require the answer to be a structured 
table with columns for scheme name, eligibility 
criteria, subsidy amount, and application link. 

### D. Vector Store (ChromaDB)
ChromaDB v0.5.3 is a persistent server process 
running on the same Oracle Cloud VM as the Spring 
Boot backend. The knowledge base has 847 text 
chunks from 12 official Karnataka government 
schemes PDFs at the time of launch. The embeddings 
are generated using the all-MiniLM-L6-v2 sentence-transformer model (384 dimensions) loaded via the 
Java bindings of HuggingFace. Running a full cosine-similarity search over all 847 chunks takes less than 40 
ms on CPU — fast enough that retrieval is never the 
bottleneck in a RAG query. 

When a new government circular is published, an 
admin uploads the pdf through a simple web form. The 
backend parses, chunks, embeds and indexes the 
circular in under 90 seconds without a restart. 

### E. Zero-Cost Infrastructure Summary
None of the costs of the production stack are monetary. 
In Table II, we list each service, the limits of its free 
tier, and how much we used it over the four-week pilot. 

**TABLE II**
**Infrastructure Cost Breakdown**

| Service | Free-Tier Limit | Our Usage (4-Week Pilot) |
| --- | --- | --- |
| Groq Cloud API | 30 RPM / 14,400 RPD | ~3,800 RPD avg |
| Firebase Realtime DB (Spark) | 1 GB storage, 10 GB/mo transfer | 340 MB stored, 2.1 GB transferred |
| Oracle Cloud Always Free (ARM) | 4 OCPUs, 24 GB RAM total | 2 OCPUs, 12 GB configured |
| data.gov.in Agmarknet API | Free developer key, no published limit | 1 call/day (batch) |
| Open-Meteo | Unlimited, no API key | ~1,200 calls/day |
| Bhashini ASR + NMT + TTS | Free government service | ~400 calls/day |
| ESA Copernicus Sentinel-2 | Free open access | ~50 tile downloads/week |

For the four-week pilot with 200 registered farmers, 
the total hosting cost was 0 rupees.

## VI. RESULTS AND DISCUSSION
KrushikaDhara was evaluated using two 
complementary approaches: a controlled benchmark 
on a held-out test set of labelled images and documents, 
and a six-week field pilot conducted from March to 
April 2025 with 42 farmers across three taluks in 
Chitradurga district — Holalkere, Hosadurga, and 
Chitradurga town.

The taluks were selected based on crop diversity. 
Pomegranate and Onion were cultivated in the dry 
northern regions, Ragi and Groundnut in the central 
belt, and Tomato and Soybean in the irrigated southern 
areas. The farmers who participated in the study ranged 
in age from 24 to 67 years. Among the 42 farmers, 14 
had not previously used a smartphone application.

The following sub sections present the quantitative 
performance metrics of each core module. 

### A. Disease Detection Accuracy
We tested the on-device TFLite model on 1200 leaf 
images in 12 disease categories. Importantly, none of 
these images were from the PlantVillage training set; 
instead, they were taken by pilot farmers using their 
own phones in real field conditions: harsh midday sun, 
partial leaf occlusion by neighboring plants, and 
different stages of growth from seedling to mature 
canopy. Table III presents the per-disease results for 
the five most important agriculture categories in the 
pilot region.

**TABLE III**
**Disease Detection Performance (Field-Captured Images)**

| Crop Disease | Precision (%) | Recall (%) | F1 Score | Inference (ms) |
| --- | --- | --- | --- | --- |
| Bacterial Blight (Pomegranate) | 92.4 | 90.1 | 0.912 | 174 |
| Leaf Rust (Ragi) | 91.7 | 93.2 | 0.924 | 181 |
| Yellow Mosaic Virus (Soybean) | 89.3 | 88.6 | 0.889 | 183 |
| Powdery Mildew (Onion) | 94.1 | 91.8 | 0.929 | 178 |
| Late Blight (Tomato) | 93.5 | 92.9 | 0.932 | 176 |
| Overall (Weighted Average) | 92.2 | 91.3 | 0.917 | 178.4 |

The weighted-average F1 of 0.917 is well above the 
threshold of 0.90 that the extension officers at UAS 
Bangalore said they would want to see before 
recommending the tool to farmers. There are two 
patterns here. First, Yellow Mosaic Virus has the 
lowest score (F1 = 0.889) which we attribute to the 
visual similarity between early-stage YMV mottling 
and normal chlorosis due to iron deficiency, a 
confusion that cannot be resolved by the model from 
just a single leaf image. Second, inference time is very 
stable across diseases (174-183 ms), confirming that 
the INT8-quantized model works at a consistent frame 
rate independent of class complexity. 

Although Mohanty et al. [1] achieved 31% accuracy on 
field images, and Ferentinos [2] obtained 99.53% 
accuracy on lab images only, our 91.7% weighted F1 
on field-captured images presents a practical trade-off: 
not perfect, but good enough that farmers in the pilot 
came to trust the app’s diagnosis more than their own 
eyes by the third week of the pilot. 

### B. Scheme Retrieval Accuracy (RAG Pipeline)
To test the RAG pipeline, we created a test set of 200 
farmer queries about Karnataka government schemes 
— half of which were typed and half were captured 
through the voice pipeline and transcribed by Bhashini. 
Questions ranged from basic eligibility queries (“If I 
have 3 acres of dry land, am I eligible for Krishi 
Bhagya?”) to more complex document checklist 
requests (“What papers do I need for KCC renewal at 
my DCC Bank branch?”). Each response was 
independently evaluated for relevance and factual 
accuracy against the source PDFs by two agricultural-extension officers from the Chitradurga district office.
The results grouped by query category are shown in 
Table IV. 

**TABLE IV**
**Scheme RAG Retrieval Evaluation Results**

| Query Category | Precision (%) | Recall (%) | MRR | Hallucination Rate |
| --- | --- | --- | --- | --- |
| Eligibility queries (Krishi Bhagya) | 95.2 | 93.1 | 0.91 | 0% |
| Document checklist queries | 96.0 | 94.5 | 0.94 | 0% |
| Loan scheme queries (KCC/NABARD) | 92.8 | 91.4 | 0.89 | 0% |
| Budget scheme queries (Vasudhamruta) | 93.5 | 90.8 | 0.88 | 0% |
| Overall | 94.3 | 92.4 | 0.905 | 0% |

### C. System Comparison with Existing Platforms
**TABLE V**
**Comparative Analysis with Existing Platforms**

| Feature | KrushikaDhara | Kisan Suvidha | AgroStar | DeHaat | Plantix |
| --- | --- | --- | --- | --- | --- |
| Offline Disease Detection | Yes | No | No | No | Partial |
| Kannada Voice Interface | Yes | No | No | No | No |
| RAG Scheme Advisory | Yes | No | No | No | No |
| Pest-Weather Alerts | Yes | Partial | Yes | Yes | Yes |
| Real-time Mandi Prices | Yes | Yes | Yes | Yes | No |
| Peer Farmer Network | Yes | No | Partial | Partial | Yes |
| Infrastructure Cost | Zero | Govt. Funded | Freemium | Freemium | Freemium |
| Karnataka-Specific Rules | Yes | Partial | No | No | No |

### D. Mandi Price Alert Latency
To monitor the delivery time of price alerts to 
farmers during morning trading windows, we 
monitored the Firebase Cloud Messaging (FCM) 
delivery times of 50 scheduled alert cycles during the 
six-week pilot. We defined end-to-end latency as the 
time elapsed between when the Spring Boot backend 
received a successful payload from the Agmarknet API 
and when the push notification rendered on the 
farmer’s device .

The average delivery latency was 3.8 seconds, 
min: 1.9 seconds, max: 9.2 seconds (standard 
deviation: 1.4s). This sub-five-second average proves 
that the Java backend can process the national JSON 
payload, filter it down to the 42 specific registered 
taluks, and dispatch the FCM tokens fast enough for 
real-time operation. 

A critical element in our system architecture 
design was the government API instability. Three 
times during the pilot the REST endpoint of 
Agmarknet was down. The backend didn’t fail silently, 
but was able to trigger its fallback of Jsoup HTML-scraping, scraping prices directly from the public 
facing Agmarknet portal. The scraping operation 
resulted in a mean latency penalty of 12.3 seconds, but 
farmers still received their daily alerts, validating the 
robustness of the fallback mechanism.

## VII. ADVANTAGES OF PROPOSED SYSTEM
KrushikaDhara architecture has many unique 
advantages compared to traditional government portals 
and commercial agritech platforms:
• **Zero-Cost Replicability:** The whole backend runs on 
Oracle Cloud’s Always Free tier, and is built entirely 
around open-source frameworks or free government 
APIs so the system can be deployed and scaled by 
agricultural universities or NGOs without the crippling 
subscription overhead common to commercial cloud 
deployments.
• **Offline-First Resilience:** The most important 
diagnostic feature still works fully deep in the fields of 
Chitradurga, where 4G connectivity is often patchy or 
unavailable, by running the quantised YOLOv8 
inference locally on the device rather than a cloud 
endpoint.
• **Strict Retrieval Grounding:** The RAG-constrained 
pipeline stops the underlying LLM from hallucinating 
government schemes, interest rates, and chemical 
dosages. This strict adherence to validated PDFs 
ensures that the safety standards for providing 
financial and agronomic advice are maintained.
• **Vernacular Accessibility:** By using Bhashini’s ASR 
and TTS end-points effectively, we can overcome the 
illiteracy hurdle. This way, farmers can talk in their 
local Kannada dialect and get answers, allowing them 
to gain access to all sorts of information and policies 
that are usually presented in English or highly 
formalized Kannada language.
• **Hyper-Local Resolution:** The use of Sentinel 2 soil 
moisture indicators together with Open-Meteo enables 
pest correlation to determine pathogen thresholds on 
the GPS locations of individual farm holdings and not 
district-level only.
• **Architectural Decoupling:** The backend services are 
separated out. The Scheme RAG module or the Mandi 
price scraper could be readily adopted as individual 
services by a state agricultural department without 
having to inherit the entire KrushikaDhara codebase. 
• **Organic Data Density:** The introduction of a peer-to-peer network creates a self-reinforcing data loop. As 
more farmers report localised pest sightings, or share 
Mandi wait times, the spatial resolution of the 
platform’s early-warning system organically improves 
for all nearby users. 

## VIII. PRACTICAL APPLICATIONS
 Beyond its use by individual farmers, the 
KrushikaDhara architecture has many macro level 
applications for state infrastructure and agricultural 
planning. 
 At the state governance level, the scheme-retrieval 
RAG module can be integrated with the existing 
network of Raitha Samparka Kendras (RSKs) as an 
assisted-digital kiosk service. This would also 
standardise the information dispensed across districts 
and greatly reduce the manual advisory workload on 
human extension officers. Similarly, the platform’s 
transport pooling and Mandi price engines are aligned 
with and support the national e-NAM (National 
Agriculture Market) digitisation mandate. 
 
 It also generates valuable secondary data for 
institutional research and risk management. 
Agricultural research universities such as UAS 
Bangalore and UAS Dharwad can use the anonymised 
geo-tagged logs of the disease detection module to 
monitor pest migration patterns and outbreak 
densities in near real time across Karnataka. The 
timestamped disease and weather-correlation logs 
offer a means of objective claim verification and 
borrower pre-screening for rural fintech institutions, 
District Co-operative Central Banks (DCCBs) and 
crop insurance providers, thereby decreasing 
customer acquisition costs and the incidence of 
fraudulent claims. 

## IX. FUTURE SCOPE
Although the present implementation of 
KrushikaDhara meets the short-term requirements of 
diagnosis and advisory for smallholder farmers, there 
are various possibilities for technical expansion. The 
following domains will be focussed on for future 
development: 

• **Federated Learning for Continuous Improvement:**
Currently, the weights of YOLOv8 are frozen after 
deployment. We will implement a federated learning 
pipeline in a future version where on-device inference 
signals, corrected by implicit farmer feedback (e.g. 
accept or reject a diagnosis), will be aggregated 
globally. This would allow the central model to 
continuously learn from new strains of pathogens 
without ever sending raw privacy-sensitive field 
images back to a central server. 
• **IoT Soil Sensor Integration:** The current crop calendar 
relies on broad satellite and weather information. 
Integration of cheap Bluetooth-enabled IoT soil sensors 
(that record local NPK, pH and moisture levels) would 
allow the Flutter client to ingest real-time, plot-specific 
agronomic data to be directly fed into the dynamic sowing 
and fertilisation recommendations. 
• **Commodity UAV Scouting:** Connecting the pest-weather correlation engine to low-cost commodity 
unmanned aerial vehicles (UAVs) has the potential to 
automate large-scale field scouting When the 
predictive engine detects a high-risk weather 
convergence, autonomous drone sweeps can generate 
canopy-level multispectral maps to identify early-stage 
blight before it's visible from the ground. 
• **Cross-Regional Scalability:** The system architecture 
is basically language and region agnostic despite being 
tuned for ten different agro-climatic zones of 
Karnataka. For example, extending deployment to 
neighbouring states like Maharashtra (Marathi) or 
Tamil Nadu (Tamil) requires no structural code 
changes – just the integration of new Bhashini 
language packs and ingestion of state-specific policy 
PDFs into the ChromaDB vector store. 
• **Distributed Ledgers for Traceability:** In the future a 
light-weight blockchain layer could be added to open 
premium export markets for farmers. The ability to 
directly log immutable, timestamped records of 
chemical input events (pesticide sprays, organic 
fertiliser applications, etc.) from the app would 
facilitate the organic certification process and ensure 
supply-chain transparency.

## X. CONCLUSION
This paper detailed the architecture and deployment of 
KrushikaDhara, an offline-first, vernacular agricultural 
intelligence platform designed specifically for the 
smallholder farmers of Karnataka. By synthesizing 
edge-based computer vision, retrieval-augmented 
generation (RAG), and government-backed neural 
machine translation, the platform addresses the severe 
connectivity and literacy barriers that typically lock 
rural populations out of modern precision agriculture.
Our quantitative evaluation over a six-week pilot in the 
Chitradurga district demonstrated that high-performance AI does not require continuous cloud 
connectivity. The INT8-quantized YOLOv8 model 
achieved a 0.917 weighted F1 score for disease 
detection operating entirely on-device, while the 
tightly constrained RAG pipeline returned a 94.3% 
precision rate on government scheme queries with zero 
hallucinated responses during the 200-query audit. 
Furthermore, the robust fallback mechanisms built into 
the Java backend ensured that time-critical market 
alerts were delivered with a mean latency of just 3.8 
seconds, even during periods of government API 
instability.

Ultimately KrushikaDhara is a technical proof of 
concept to democratise agriculture technology. The 
intelligent combination of open-source models, free-tier cloud infrastructure and open government data 
have demonstrated how enterprise-grade, deeply 
localised agronomic advisory systems can be built, 
deployed and scaled at zero operational cost, providing 
a sustainable blueprint for digital agriculture in the 
Global South.

## REFERENCES
[1] S. P. Mohanty, D. P. Hughes, and M. Salathé, "Using deep 
learning for image-based plant disease detection," Frontiers in Plant 
Science, vol. 7, p. 1419, Sep. 2016. doi: 10.3389/fpls.2016.01419.
[2] K. P. Ferentinos, "Deep learning models for plant disease 
detection and diagnosis," Computers and Electronics in Agriculture, 
vol. 145, pp. 311–318, Feb. 2018. doi: 
10.1016/j.compag.2018.01.009.
[3] A. Kamilaris and F. X. Prenafeta-Boldú, "Deep learning in 
agriculture: A survey," Computers and Electronics in Agriculture, 
vol. 147, pp. 70–90, Apr. 2018.
[4] B. Jacob et al., "Quantization and training of neural networks 
for efficient integer-arithmetic-only inference," in Proc. IEEE Conf. 
Comput. Vis. Pattern Recognit. (CVPR), 2018, pp. 2704–2713.
[5] S. Mittal and M. Mehar, "Socio-economic impact of mobile 
phones on Indian agriculture," ICRIER Working Paper No. 246, 
Indian Council for Research on International Economic Relations, 
Feb. 2012.
[6] M. Fafchamps and B. Minten, "Impact of SMS-based 
agricultural information on Indian farmers," The World Bank 
Economic Review, vol. 26, no. 3, pp. 383–414, 2012.
[7] P. Lewis et al., "Retrieval-augmented generation for knowledge-intensive NLP tasks," in Advances in Neural Information 
Processing Systems (NeurIPS), vol. 33, 2020, pp. 9459–9474.
[8] Y. Gao et al., "Retrieval-augmented generation for large 
language models: A survey," arXiv preprint arXiv:2312.10997, 
2023.
[9] G. N. Agrios, Plant Pathology, 5th ed. Burlington, MA: Elsevier 
Academic Press, 2005.
[10] S. Vennila et al., "Pest management decision support systems," 
ICAR-National Research Centre for Integrated Pest Management, 
New Delhi, India, Tech. Bull. 38, 2019.
[11] D. B. Lobell et al., "Eyes in the sky, boots on the ground: 
Assessing satellite- and ground-based approaches to crop yield 
measurement and analysis," American Journal of Agricultural 
Economics, vol. 102, no. 1, pp. 202–219, 2020.
[12] Ministry of Electronics and Information Technology, 
"Bhashini: National Language Translation Mission," Gov. of India, 
2022. [Online]. Available: https://bhashini.gov.in
[13] Open-Meteo, "Open-Meteo: Free Weather API," 2023. 
[Online]. Available: https://open-meteo.com
[14] A. Jocher, A. Chaurasia, and J. Qiu, "YOLO by Ultralytics," 
2023. [Online]. Available: https://github.com/ultralytics/ultralytics