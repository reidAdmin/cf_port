package readPCP;

import com.lowagie.text.pdf.PdfArray;
import com.lowagie.text.pdf.PdfDictionary;
import com.lowagie.text.pdf.PdfName;
import com.lowagie.text.pdf.PdfObject;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfString;
import java.util.ListIterator;

public class ReadPDF {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		try {
			System.out.println("Hi in the Comments test");
			PdfReader reader = new PdfReader("testForm4.pdf");
			
			for (int i=1; i<=reader.getNumberOfPages(); i++) {
				
				PdfDictionary page = reader.getPageN(i);
				PdfArray annotsArray = null;
				
				if(page.getAsArray(PdfName.ANNOTS) == null)
					continue;
				
				annotsArray = page.getAsArray(PdfName.ANNOTS);
				
				for (ListIterator iter = annotsArray.listIterator(); iter.hasNext();) {
					
					PdfDictionary annot = (PdfDictionary)PdfReader.getPdfObject(iter.next());
					PdfString content =  (PdfString);
					PdfReader.getPdfObject(annot.get(PdfName.CONTENTS));
					
					if(content != null) {
						System.out.println(content);
					}
					
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	

	}

}
