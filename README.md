# MeToo
This is the replication package for the paper titled "Economics Coauthorships in the Aftermath of MeToo" by Noriko Amano-Patiño, Elisa Faraglia, Chryssi Giannitsarou.

To replicate figures, tables, and estimates:

1. **Download the `Replication_MeToo` folder**. This folder contains two main directories:
   - **Programs**: Includes all the necessary Stata code files.
   - **Data**: Contains the zipped data folder required to run the analyses. To obtain the password for the zipped folder, please email [metoo@econ.cam.ac.uk](mailto:metoo@econ.cam.ac.uk) . Once you receive the password, unzip the folder, ensuring that the original folder structure is preserved.

2. **Create the folders to store the output produced when running the code**:
   - Open the `Replication_MeToo/Programs/master_MeToo.do` file.
   - The first time you run this code, uncomment lines 14-18 to create necessary folders (`Tables`, `Figures`, `TempOutput_Regressions`).
   - Before running the summary statistics portion of the codes, also uncomment lines 43-48 to create subfolders within `Data/tables_'sample'` for each sample type (`allaut`, `onlyju`, `senior`).
   - Once these folders are created, you can re-comment these lines: they will produce an error if you run them once the folders exist.

3. **Install packages to run the figures' codes**. The non-standard packages we use in the codes are to make figures, namely, `colorpalette` and `grc1leg`. 
   - `colorpalette`: This package ensures our graphs are color-blind friendly and requires the `colrspace` package. To install, type:
     ```
     ssc install colrspace
     ```
      This package requires version 14.2 of Stata or newer. Users of older Stata versions can use command colorpalette9, which has limited functionality but runs under Stata 9.2 or newer.
   - `grc1leg`: This package allows to combine plots that share the same legend. To install, type: 
	```
     net from http://www.stata.com
     net cd users
     net cd vwiggins
     net install grc1leg
     ```
   - After installing these packages, you should be able to run the entire `master_MeToo.do` file without further modifications.

4. **Code Structure**. The `master_MeToo.do` file provides detailed descriptions of inputs and outputs for each code segment.
   
5. **Output**. The regression outputs are saved in CSV files. The figures are saved as PDFs or SVG files. We use SVG files for figures that require additional editing to make legends fully visible or remove unnecessary elements.

If you encounter any problems when running the codes, please reach out to Noriko Amano-Patiño (noriko.amanopatino@econ.cam.ac.uk), who is responsible for any errors and was the primary author of the codes.
