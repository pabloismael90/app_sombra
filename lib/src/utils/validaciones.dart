

bool isNumeric(String value){

    if (value.isEmpty){
        //print(value);
        return false;
    } 

    final numero = num.parse(value);
    return (numero == null ) ? false : true;
      
}


