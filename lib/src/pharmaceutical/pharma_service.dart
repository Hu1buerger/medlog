import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

class PharmaService{

  int lastID = 0;

  int getNextFreeID(){
    return ++lastID;
  }

  Future<List<Pharmaceutical>> load() async{
    return [
      Pharmaceutical(DocumentState.user_created, "Medikinet 20mg", "20mg", "Methylphenidat"),
      Pharmaceutical(DocumentState.user_created, "Medikinet 40mg", "40mg", "Methlyphanidat"),
      Pharmaceutical(DocumentState.user_created, "Medikinet 60mg", "60mg", "Methlyphanidat"),
      Pharmaceutical(DocumentState.user_created, "Ritalin 20mg", "20mg", "Methlyphanidat"),
      Pharmaceutical(DocumentState.user_created, "Ritalin 40mg", "40mg", "Methlyphanidat"),
      Pharmaceutical(DocumentState.user_created, "Hulio 40mg", "40mg", "Adalimumab"),
    ];
  }

  Future save() async{

  }
}