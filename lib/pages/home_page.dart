import 'dart:io';

import 'package:contact_book/database/contact.dart';
import 'package:contact_book/pages/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactDb contactDb = ContactDb();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(),
      backgroundColor: Colors.white,
      floatingActionButton: buildFloatingActionButton(),
      body: buildBody(),
    );
  }

  buildAppbar() {
    return AppBar(
      title: Text("Contatos"),
      centerTitle: true,
      backgroundColor: Colors.black,
      actions: [
        PopupMenuButton<OrderOptions>(
          itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordenar de A-Z"),
              value: OrderOptions.orderaz,
            ),
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordenar de Z-A"),
              value: OrderOptions.orderza,
            ),
          ],
          onSelected: orderList,
        ),
      ],
    );
  }

  buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showContactPage();
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.black,
    );
  }

  buildBody() {
    return ListView.builder(
      itemCount: contacts.length,
      padding: EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return contactCard(context, index);
      },
    );
  }

  Widget contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img))
                          : AssetImage("images/user.png"),
                      fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (contacts[index].name) ?? "",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      (contacts[index].email) ?? "",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      (contacts[index].phone) ?? "",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        showOptions(context, index);
      },
    );
  }

  void showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact,
        ),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await contactDb.updateContact(recContact);
      } else {
        await contactDb.saveContact(recContact);
      }
      await getAllContacts();
    }
  }

  void getAllContacts() {
    contactDb.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(
                            child: Text(
                              "Ligar",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            onPressed: () {
                              launch("tel:${contacts[index].phone}");
                              Navigator.pop(context);
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(
                          child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            showContactPage(contact: contacts[index]);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          onPressed: () {
                            contactDb.deleteContact(contacts[index].id);
                            setState(() {
                              contacts.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort(((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }));
        break;
      case OrderOptions.orderza:
        contacts.sort(((b, a) {
          return b.name.toLowerCase().compareTo(b.name.toLowerCase());
        }));
        break;
    }
    setState(() {});
  }
}
