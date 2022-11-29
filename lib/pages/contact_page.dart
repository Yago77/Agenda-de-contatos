import 'dart:io';

import 'package:flutter/material.dart';

import '../database/contact.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  const ContactPage({Key key, this.contact}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final nameFocus = FocusNode();

  bool userEdited = false;
  Contact editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      editedContact = Contact();
    } else {
      editedContact = Contact.fromMap(widget.contact.toMap());
      nameController.text = editedContact.name;
      emailController.text = editedContact.email;
      phoneController.text = editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => requestPop(),
      child: Scaffold(
        appBar: buildAppBar(),
        floatingActionButton: buildFloatingActionButton(),
        body: buildBody(),
      ),
    );
  }

  buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(editedContact.name ?? "Novo Contato"),
      centerTitle: true,
    );
  }

  buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        if (editedContact.name != null && editedContact.name.isNotEmpty) {
          Navigator.pop(context, editedContact);
        } else {
          FocusScope.of(context).requestFocus(nameFocus);
        }
      },
      child: Icon(Icons.save_rounded),
      backgroundColor: Colors.black,
    );
  }

  buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          GestureDetector(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: editedContact.img != null
                        ? FileImage(File(editedContact.img))
                        : AssetImage("images/user.png"),
                    fit: BoxFit.cover),
              ),
            ),
            onTap: () {
              ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                if (file == null) return;
                setState(() {
                  editedContact.img = file.path;
                });
              });
            },
          ),
          TextField(
            textCapitalization: TextCapitalization.sentences,
            focusNode: nameFocus,
            controller: nameController,
            decoration: InputDecoration(labelText: "Nome"),
            onChanged: (text) {
              userEdited = true;
              setState(() {
                editedContact.name = text;
              });
            },
          ),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Email"),
            onChanged: (text) {
              userEdited = true;
              editedContact.email = text;
            },
          ),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: "Telefone"),
            onChanged: (text) {
              userEdited = true;
              editedContact.phone = text;
            },
          ),
        ],
      ),
    );
  }

  requestPop() {
    if (userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar Mudanças?"),
            content: Text("Se sair as alterações serão perdidas."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Sim"),
              )
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
