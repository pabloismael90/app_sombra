
bool isNumeric(String? value){

    if (value == null) {
        return false;
    }
    return double.tryParse(value) !=  null;
      
}

validateEntero(String? value){
    final isDigitsOnly = int.tryParse(value!);
    if (isDigitsOnly == null) {
        return 'Solo números enteros';
    }
    if (isDigitsOnly <= 0) {
        return 'Valor invalido';
    }else{
        return null;
    }
}

validateFloat(String? value){
    
    if (isNumeric(value!)){
        return null;
    }else{
        return 'Valor $value inválido';
    }
}

floatPositivo(String? value){
    
    if (isNumeric(value!)){
        if (double.parse(value) <= 0){
            return 'Valor $value inválido';
        }
        return null;
    }else{
        return 'Valor $value inválido';
    }
}

floatSiCero(String? value){
    
    if (isNumeric(value!)){
        if (double.parse(value) < 0){
            return 'Valor $value inválido';
        }
        return null;
    }else{
        return 'Valor $value inválido';
    }
}

validateSelect(String? value){
    if(value!.length < 1){
        return 'Selecione un elemento';
    }else{
        return null;
    } 
}

validateString(String? value){
    if(value!.length == 0){
        return 'Campo Vacio';
    }else if(value.length < 3){
        return 'Texto muy corto';
    }else{
        return null;
    }
}




