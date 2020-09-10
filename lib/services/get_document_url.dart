class PatentDocument {
  static String getPatentUrl(String patent_number) {
    String first;
    String second;
    String third;
    String url;

    if (patent_number.length == 7) {
      first = patent_number[0] + patent_number[1];
      second = patent_number[2] + patent_number[3] + patent_number[4];
      third = patent_number[5] + patent_number[6];

      if (PatentDocument.isNumeric(first) == true) {
        first = "0" + first;
      } else {
        first = first + "0";
      }

      ///full document
      url = "https://pimg-fpiw.uspto.gov/fdd/$third/$second/$first/0.pdf";

      ///front page only
      // url = "https://pdfpiw.uspto.gov/$third/$second/$first/1.pdf";
    } else if (patent_number.length == 8) {
      first = patent_number[0] + patent_number[1] + patent_number[2];
      second = patent_number[3] + patent_number[4] + patent_number[5];
      third = patent_number[6] + patent_number[7];

      ///full document
      url = "https://pimg-fpiw.uspto.gov/fdd/$third/$second/$first/0.pdf";

      ///front page only
      //url = "https://pdfpiw.uspto.gov/$third/$second/$first/1.pdf";
    }

    return url;
  }

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
