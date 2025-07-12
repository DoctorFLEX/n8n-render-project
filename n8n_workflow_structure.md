# N8n Workflow Structure

## Workflow: ContextEngineer10Jul25
ID: ryHZkbtSJOGaivgN
Status: Inactive
Version ID: 2c716c90-eaf4-4f9c-9d8b-b3c700660dbe

## Nodes (85)
### Node Types:
- n8n-nodes-base.stickyNote: 21 nodes
- n8n-nodes-base.set: 12 nodes
- @n8n/n8n-nodes-langchain.chainLlm: 6 nodes
- @n8n/n8n-nodes-langchain.lmChatOpenAi: 5 nodes
- n8n-nodes-base.notion: 5 nodes
- @n8n/n8n-nodes-langchain.outputParserStructured: 4 nodes
- n8n-nodes-base.splitOut: 4 nodes
- n8n-nodes-base.form: 4 nodes
- n8n-nodes-base.splitInBatches: 3 nodes
- n8n-nodes-base.executeWorkflow: 3 nodes
- n8n-nodes-base.if: 3 nodes
- n8n-nodes-base.httpRequest: 2 nodes
- n8n-nodes-base.filter: 2 nodes
- n8n-nodes-base.formTrigger: 1 nodes
- n8n-nodes-base.noOp: 1 nodes
- n8n-nodes-base.executeWorkflowTrigger: 1 nodes
- n8n-nodes-base.executionData: 1 nodes
- n8n-nodes-base.switch: 1 nodes
- n8n-nodes-base.markdown: 1 nodes
- @n8n/n8n-nodes-langchain.lmChatGoogleGemini: 1 nodes
- n8n-nodes-base.merge: 1 nodes
- n8n-nodes-base.code: 1 nodes
- n8n-nodes-base.aggregate: 1 nodes
- n8n-nodes-base.stopAndError: 1 nodes

### Node Details:
#### Structured Output Parser (@n8n/n8n-nodes-langchain.outputParserStructured)
ID: a342005e-a88e-419b-b929-56ecbba4a936
Parameters:
  - schemaType: manual
  - inputSchema: {
  "type": "object",
  "properties": {
    "le...
Position: (4100, 2600)

#### Set Variables (n8n-nodes-base.set)
ID: 126b8151-6d20-43b8-8028-8163112c4c5b
Parameters:
  - assignments: {'assignments': [{'id': 'df28b12e-7c20-4ff5-b5b...
  - options: {}
Position: (1440, 960)

#### OpenAI Chat Model (@n8n/n8n-nodes-langchain.lmChatOpenAi)
ID: 1d0fb87b-263d-46c2-b016-a29ba1d407ab
Parameters:
  - model: {'__rl': True, 'mode': 'id', 'value': 'o3-mini'}
  - options: {}
Position: (3920, 2600)

#### OpenAI Chat Model1 (@n8n/n8n-nodes-langchain.lmChatOpenAi)
ID: 39b300d9-11ba-44f6-8f43-2fe256fe4856
Parameters:
  - model: {'__rl': True, 'mode': 'id', 'value': 'o3-mini'}
  - options: {}
Position: (1940, 3180)

#### OpenAI Chat Model2 (@n8n/n8n-nodes-langchain.lmChatOpenAi)
ID: 018da029-a796-45c5-947c-791e087fe934
Parameters:
  - model: {'__rl': True, 'mode': 'id', 'value': 'o3-mini'}
  - options: {}
Position: (1740, 1120)

#### Structured Output Parser1 (@n8n/n8n-nodes-langchain.outputParserStructured)
ID: 525da936-a9eb-4523-b27a-ff6ae7b0e5ef
Parameters:
  - schemaType: manual
  - inputSchema: {
  "type": "object",
  "properties": {
    "qu...
Position: (1960, 1120)

#### On form submission (n8n-nodes-base.formTrigger)
ID: e6664883-cff4-4e09-881e-6b6f684f9cac
Parameters:
  - formTitle:  DeepResearcher
  - formDescription: =DeepResearcher is a multi-step, recursive appr...
  - formFields: {'values': [{'fieldType': 'html'}]}
  - options: {'buttonLabel': 'Next', 'path': 'deep_research'...
Position: (1040, 960)

#### Generate SERP Queries (@n8n/n8n-nodes-langchain.chainLlm)
ID: 6b8ebc08-c0b1-4af8-99cc-79d09eea7316
Parameters:
  - promptType: define
  - text: =Given the following prompt from the user, gene...
  - hasOutputParser: True
  - messages: {'messageValues': [{'type': 'HumanMessagePrompt...
Position: (1760, 2240)

#### Structured Output Parser2 (@n8n/n8n-nodes-langchain.outputParserStructured)
ID: 34e1fa5d-bc0c-4b9e-84a7-35db2b08c772
Parameters:
  - schemaType: manual
  - inputSchema: {
  "type": "object",
  "properties": {
    "qu...
Position: (1940, 2400)

#### OpenAI Chat Model3 (@n8n/n8n-nodes-langchain.lmChatOpenAi)
ID: be6dd6a2-aacf-4682-8f13-8ae24c4249a3
Parameters:
  - model: {'__rl': True, 'mode': 'id', 'value': 'o3-mini'}
  - options: {}
Position: (1760, 2400)

... and 75 more nodes

## Connections
Total connections: 68

### Connection Details:
- Item Ref (main) → RAG Web Browser (main:0)
- Create Row (main) → Initiate DeepResearch (main:0)
- Confirmation (main) → End Form (main:0)
- Has Content? (main) → Get Markdown + URL (main:0)
- Has Content? (main) → Empty Response (main:0)
- Valid Blocks (main) → Append Blocks (main:0)
- Append Blocks (main) → For Each Block... (main:0)
- HTML to Array (main) → Tags to Items (main:0)
- SERP to Items (main) → For Each Query... (main:0)
- Set Variables (main) → Clarifying Questions (main:0)
- Tags to Items (main) → Notion Block Generator (main:0)
- Valid Results (main) → Has Content? (main:0)
- Empty Response (main) → For Each Query... (main:0)
- Execution Data (main) → JobType Router (main:0)
- JobType Router (main) → Get Existing Row (main:0)
- JobType Router (main) → Generate SERP Queries (main:0)
- JobType Router (main) → Get Existing Row1 (main:0)
- Convert to HTML (main) → HTML to Array (main:0)
- RAG Web Browser (main) → Is Apify Auth Error? (main:0)
- Set In-Progress (main) → Set Initial Query (main:0)
- Get Existing Row (main) → Set In-Progress (main:0)
- Research Request (main) → Set Variables (main:0)
- Results to Items (main) → Set Next Queries (main:0)
- Set Next Queries (main) → Generate Learnings (main:0)
- Feedback to Items (main) → For Each Question... (main:0)
- For Each Block... (main) → Set Done (main:0)
- For Each Block... (main) → Upload to Notion Page (main:0)
- For Each Query... (main) → Combine & Send back to Loop (main:0)
- For Each Query... (main) → Item Ref (main:0)
- Get Existing Row1 (main) → DeepResearch Report (main:0)
- Get Initial Query (main) → Report Page Generator (main:0)
- Is Depth Reached? (main) → Get Research Results (main:0)
- Is Depth Reached? (main) → DeepResearch Results (main:0)
- OpenAI Chat Model (ai_languageModel) → DeepResearch Learnings (ai_languageModel:0)
- Parse JSON blocks (main) → Valid Blocks (main:0)
- Parse JSON blocks (main) → URL Sources to Lists (main:0)
- Set Initial Query (main) → Generate Learnings (main:0)
- Accumulate Results (main) → Is Depth Reached? (main:0)
- Generate Learnings (main) → Accumulate Results (main:0)
- Get Markdown + URL (main) → DeepResearch Learnings (main:0)
- On form submission (main) → Research Request (main:0)
- OpenAI Chat Model1 (ai_languageModel) → DeepResearch Report (ai_languageModel:0)
- OpenAI Chat Model2 (ai_languageModel) → Clarifying Questions (ai_languageModel:0)
- OpenAI Chat Model3 (ai_languageModel) → Generate SERP Queries (ai_languageModel:0)
- OpenAI Chat Model4 (ai_languageModel) → Report Page Generator (ai_languageModel:0)
- DeepResearch Report (main) → Convert to HTML (main:0)
- Clarifying Questions (main) → Feedback to Items (main:0)
- DeepResearch Results (main) → Results to Items (main:0)
- For Each Question... (main) → Get Initial Query (main:0)
- For Each Question... (main) → Ask Clarity Questions (main:0)
- Get Research Results (main) → Generate Report (main:0)
- Is Apify Auth Error? (main) → Stop and Error (main:0)
- Is Apify Auth Error? (main) → Valid Results (main:0)
- URL Sources to Lists (main) → Append Blocks (main:1)
- Ask Clarity Questions (main) → For Each Question... (main:0)
- Generate SERP Queries (main) → SERP to Items (main:0)
- Initiate DeepResearch (main) → Confirmation (main:0)
- Report Page Generator (main) → Create Row (main:0)
- Upload to Notion Page (main) → For Each Block... (main:0)
- DeepResearch Learnings (main) → Research Goal + Learnings (main:0)
- Notion Block Generator (main) → Parse JSON blocks (main:0)
- DeepResearch Subworkflow (main) → Execution Data (main:0)
- Google Gemini Chat Model (ai_languageModel) → Notion Block Generator (ai_languageModel:0)
- Structured Output Parser (ai_outputParser) → DeepResearch Learnings (ai_outputParser:0)
- Research Goal + Learnings (main) → For Each Query... (main:0)
- Structured Output Parser1 (ai_outputParser) → Clarifying Questions (ai_outputParser:0)
- Structured Output Parser2 (ai_outputParser) → Generate SERP Queries (ai_outputParser:0)
- Structured Output Parser4 (ai_outputParser) → Report Page Generator (ai_outputParser:0)

## Additional Properties
- pinData: {}
- settings: {}
- meta: {'templateId': '2878', 'instanceId': 'af39484fe...
- tags: []