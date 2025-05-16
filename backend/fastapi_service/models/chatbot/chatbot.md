# Pediatric Diseases and Symptoms Dataset

## Overview
This dataset (`intents.json`) is designed to support a chatbot or virtual assistant focused on pediatric health. It contains a collection of intents related to common diseases and symptoms in children, with patterns reflecting how parents might describe their child's condition and responses providing basic information and care advice. The dataset is structured to assist users in identifying potential health issues and encourages consulting a pediatrician for proper diagnosis and treatment.

## Pediatric Diseases and Symptoms Covered
The dataset includes the following 25 diseases and symptoms commonly affecting children, with associated patterns and responses tailored for parents:

1. **Fever** (`fever_children`): High body temperature, often a sign of infection.
2. **Common Cold** (`cold_children`): Runny nose, cough, and sneezing.
3. **Ear Infection** (`ear_infection_children`): Ear pain, fever, and irritability, often following a cold.
4. **Strep Throat** (`strep_throat_children`): Sore throat, fever, and swollen lymph nodes.
5. **Chickenpox** (`chickenpox_children`): Itchy rash with blisters and fever.
6. **Measles** (`measles_children`): High fever, cough, red eyes, and rash.
7. **Mumps** (`mumps_children`): Swollen salivary glands and fever.
8. **Whooping Cough** (`whooping_cough_children`): Severe coughing fits with a "whooping" sound.
9. **Croup** (`croup_children`): Barking cough and hoarseness.
10. **Bronchiolitis** (`bronchiolitis_children`): Wheezing and breathing difficulties, often caused by RSV.
11. **Gastroenteritis** (`gastroenteritis_children`): Vomiting, diarrhea, and stomach cramps.
12. **Conjunctivitis** (`conjunctivitis_children`): Red, itchy eyes, also known as pink eye.
13. **Hand, Foot, and Mouth Disease** (`hand_foot_mouth_disease_children`): Mouth sores and rash on hands and feet.
14. **Fifth Disease** (`fifth_disease_children`): "Slapped cheek" rash and mild fever.
15. **Roseola** (`roseola_children`): High fever followed by a rash.
16. **Impetigo** (`impetigo_children`): Crusty, oozing sores, typically on the face.
17. **Ringworm** (`ringworm_children`): Red, ring-shaped rash caused by a fungal infection.
18. **Scabies** (`scabies_children`): Intense itching and rash due to mites.
19. **Head Lice** (`lice_children`): Itchy scalp caused by tiny insects.
20. **Rash** (`rash_children`): General skin rash, potentially caused by various factors.
21. **Eczema** (`eczema_children`): Dry, itchy, red skin patches (proposed addition).
22. **Food Allergies** (`food_allergies_children`): Rashes, swelling, or breathing issues after eating certain foods (proposed addition).
23. **Asthma** (`asthma_children`): Wheezing and difficulty breathing, often triggered by allergens (proposed addition).
24. **Sinusitis** (`sinusitis_children`): Nasal congestion and facial pain (proposed addition).
25. **Teething** (`teething_children`): Drooling, fussiness, and chewing during tooth eruption (proposed addition).

## Dataset Structure
Each intent in the `intents.json` file follows this structure:
- **Tag**: A unique identifier for the disease or symptom (e.g., `fever_children`).
- **Patterns**: A list of phrases parents might use to describe their child's condition (e.g., "My child has a fever.").
- **Responses**: A list of informative responses providing basic care advice and encouraging medical consultation (e.g., "A fever is generally considered to be a temperature of 100.4°F (38°C) or higher in children.").

## Sources
The information in this dataset is derived from reputable medical sources to ensure accuracy and reliability. Key sources include:
- **Centers for Disease Control and Prevention (CDC)**: [https://www.cdc.gov/parents/children/diseases-and-conditions.html](https://www.cdc.gov/parents/children/diseases-and-conditions.html)
- **American Academy of Pediatrics (HealthyChildren.org)**: [https://www.healthychildren.org/English/health-issues/conditions/treatments/Pages/10-Common-Childhood-Illnesses-and-Their-Treatments.aspx](https://www.healthychildren.org/English/health-issues/conditions/treatments/Pages/10-Common-Childhood-Illnesses-and-Their-Treatments.aspx)
- **Nemours KidsHealth**: [https://kidshealth.org/en/parents/infections/](https://kidshealth.org/en/parents/infections/)
- **Johns Hopkins Medicine**: [https://www.hopkinsmedicine.org/health/wellness-and-prevention/common-childhood-illnesses](https://www.hopkinsmedicine.org/health/wellness-and-prevention/common-childhood-illnesses)

## Usage
This dataset can be used to train a chatbot or virtual assistant to assist parents in understanding common pediatric health issues. The patterns and responses are designed to be conversational and parent-friendly, with an emphasis on encouraging professional medical advice for accurate diagnosis and treatment.

## Notes
- The dataset is not a substitute for professional medical advice. Users should always consult a pediatrician for proper diagnosis and treatment.
- Proposed additions (e.g., eczema, food allergies) are included to enhance coverage but require integration into the `intents.json` file.
- Some responses may need further customization to provide more specific care instructions or to address regional healthcare practices.

## Contributors
- **Abdelrahman Menisy**: Team leader and AI developer.
- **Mohamed Ghaly**: Application developer.
- **Nour**: Application developer.