# Meeting 1: Stakeholder Alignment
Team: Amazon Reviewers
Date/Time: <2026-03-04 09:08>
Duration: 47 minutes
Facilitator (PM): Vishalkiran
Notetaker: Jasleen


Goal of the meeting:
Align on one stakeholder persona, one decision question, sprint scope, and assigned action items.


1) Quick round (5 min)
  - Each person: one sentence on what the stakeholder needs from this dataset.
   - Jasleen: The stakeholder primarily needs to understand how the star rating of a product and how many ratings said product has impacts a consumer’s decision to buy a product from their platform. 
   - Pranavi: The stakeholder most likely doesn’t understand code, so we need to make the code easy to understand for them so they can know that this dataset can provide important information for their online shopping business.
   - Vishalkiran: Agreed with what Jasleen said.
   - Tunir: Didn’t say anything when asked.


2) Stakeholder persona (10 min)
  - Who are they (role and context)?
   + Boss/owner of an online shopping business
  - What do they care about (top 3 priorities)?
   + Making lots of money on their shopping platform.
   + Maintaining good ratings on their platform.
   + Maintaining good sales over a long period of time.
  - What constraints do they have (time, budget, risk tolerance)?
   + Budget – they don’t want to spend more money maintaining a shopping platform than they are making from their shopping platform.
   + Risk – don’t want to seem unreliable to current/future customers


Decision:
Stakeholder persona = Boss/owner of an online shopping business


3) Decision question (10 to 15 min)
  - Draft 2 to 3 candidate decision questions and select one.
  - Checklist:
   + Answerable with our data
   + Relevant to a real decision
   + Supportable with 3 to 5 evidence artifacts within 2 weeks
  - Draft Questions
   + Can the stakeholder rely on their products having good star ratings for a customer to buy them?
   + Is there a correlation between the number of ratings a product has, the overall rating the product has, and how many people have bought the product?


Final decision question (one sentence):
- Can the stakeholder rely on their products having good star ratings for a customer to buy them?


4) Success criteria (5 min)
  - SC1: If a product completes (meaning has uncorrupted data) for our three requirements – overall star rating, number of ratings an item has, and number of sales an item has had within the last month (that this data was collected)
  - SC2: We can provide a clear yes or no answer to stakeholder persona supported by data artifacts.
  - SC3: Ensure every team member contributes during meetings to better our teamwork.


5) Scope exclusions (5 min)
  - What we will not do this sprint:
   + Not doing: Doing everything at the last minute.
   + Not doing: Having bad communication.
   + Not doing: Only focusing on data analysis, instead prioritize teamwork!


6) Evidence brainstorm (10 min)
  - Candidate evidence artifacts:
   + Artifact 1: Trend Graph between price of item and rating of item
    * to see if stakeholder would need to spend more or less money on products to sell them well
   + Artifact 2: Multiple Top-N entity list with the four columns – product ID, number of ratings, overall rating, number of purchased within last month
    * for the correlation graph
   + Artifact 3: Correlation Graph between 3 variables for each category chosen to analyze (3D scatterplot/bubble graph or using matrices on excel)
    * to see if there truly is any correlation between the 3 variables
   + Trust check: Making sure data is clean and doesn’t have any corruption in it.
   + Assumption test: Making sure there are no duplicate item IDs in the dataset.


7) Risks and limitations (5 to 10 min)
  - Finalize 3 to 5 bullets. Make them specific.
   + Ratings are biased/fake – like they’re botted
   + Lot of data is missing – like there’s a lot of corrupted data causing us to lessen our sample size
   + There isn’t any correlation at all – or only correlation between two of the three categories


8) Action items (10 min)
  - List tasks with owners and due dates (these become sprint board tickets).
   + Jasleen: Creating meeting1agenda.md (due 3/6)
   + Jasleen: Creating meeting1notes.md (due 3/6)
   + Jasleen: Creating meeting1actionitems.md (due 3/6)
   + Jasleen: Creating riskregister.md (due 3/6)
   + Jasleen: Creating trend graph (due 3/8)
   + Pranavi: Creating around 1 Top-N lists with four columns for top category (due 3/8)
   + Pranavi: Creating around 1 Top-N lists with four columns for 2nd category (due 3/8)
   + Pranavi: Creating around 1 Top-N lists with four columns for 3rd category (due 3/8)
   + Jasleen: Creating Correlation Graph based on the Top-N lists (due 3/9)
   + Pranavi: Cleaning up data (due 3/6)
   + Tunir: Complete things from previous sprint – fix script and datacard (due 3/6)
   + Vishalkiran: Create PM Board with detailed descriptions/expectations (due 3/6)
   + Vishalkiran: Set up meeting 2 (due 3/6)
   + Vishalkiran: Check in with group members making sure everything is going well (due 3/12)


9) Wrap (2 min)
  - Confirm stakeholder persona, decision question, and next steps.
   + Stakeholder: boss of online shopping company
   + Decision question: Can the stakeholder rely on their products having good star ratings for a customer to buy them?
   + Next Steps: do the action items by the due dates listed and communicate with one another!!

