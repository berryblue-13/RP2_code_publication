# RP2_code_publication
This repository serves to provide insight for report readers into the code used in my project.

## Getting Started and Structure

1. **Create a folder on your computer**  
   I called mine `Project`.  

2. **Open a terminal** in that folder (right click > open in terminal).  

3. **Clone this repository**  
   - On the public repository, find the green button that says "< > Code" and copy the HTTPS link.
   - In the terminal window you opened earlier, type "git clone", paste the link, hit enter.
   - If this produces an error you may not have Git installed. In that case you should first run the following code first to install Git:

```
winget install --id Git.Git -e --source winget
```

4. **Open Orphans.R** and make sure to insert the full path to your project folder on line 5.  

5. **Add data to the folder**  
    - The data is not shared publicly for privacy reasons, please get in contact at _s.j.molenaar (at) umail.leidenuniv.nl_ or _am.pasmooij (at) cbg-meb.nl_.

After this, your directory should look like this:

---
```
Project/
├── EMRD_for_Rstud.txt
├── LICENSE
├── Orphans.R
└── README
└── repurposing and type II for rstud with index.txt
```

6. **Source Orphans.R**. Before doing this, make sure all required packages are installed. Consult lines 6-9 of Orphans.R for this.