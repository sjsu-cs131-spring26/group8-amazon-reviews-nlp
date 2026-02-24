# Dataset Download Instructions

Dataset: Amazon Product Reviews  
Source: Kaggle  
https://www.kaggle.com/datasets/saurav9786/amazon-product-reviews

## Option 1: Download via Kaggle Website
1. Open the Kaggle link above.
2. Click Download.
3. Unzip the file:
   unzip amazon-product-reviews.zip -d amazon_reviews
4. Verify files:
   ls amazon_reviews

## Option 2: Download via Kaggle CLI (Recommended)
1. Install Kaggle CLI:
   python3 -m pip install --user kaggle

2. Create API token:
   Kaggle Profile → Account → API → Create New API Token

3. Set up token:
   mkdir -p ~/.kaggle
   mv kaggle.json ~/.kaggle/
   chmod 600 ~/.kaggle/kaggle.json

4. Download dataset:
   kaggle datasets download -d saurav9786/amazon-product-reviews
   unzip amazon-product-reviews.zip -d amazon_reviews


5. COMMIT no.2 :: added most popular categories, and most popular items, based on how much people buy them.



## Notes
- Do NOT commit dataset files to GitHub.
- Only instructions and code should be tracked.

