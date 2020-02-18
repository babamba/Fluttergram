import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostPage extends StatefulWidget {

  final FirebaseUser user;
  PostPage(this.user);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final textEditingController = TextEditingController();

  File _image;
//  Future _getImage() async { //메서드
//    print('클릭 되나');
//    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
//    setState(() {
//      _image = image;
//    });
//  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getImage(),
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _image == null ? Text('No Image') : Image.file(_image),

          TextField(
            decoration: InputDecoration(hintText: '내용을 입력하세요'),
            controller: textEditingController,
          )
        ],
      ),
    );
  }

  Widget _buildAppbar() {
    return AppBar(
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.send), 
          onPressed: (){
            final firebaseStorageRef = FirebaseStorage.instance.ref().child('post').child('${DateTime.now().millisecondsSinceEpoch}.png');

            final task = firebaseStorageRef.putFile(
              _image, StorageMetadata(contentType: 'image/png')
            );
            
            task.onComplete.then((value){
              var downloadUrl = value.ref.getDownloadURL();
              downloadUrl.then((uri){
                var doc = Firestore.instance.collection('post').document();
                doc.setData({
                  'id':doc.documentID,
                  'photoUrl': uri.toString(),
                  'contents': textEditingController.text,
                  'email': widget.user.email,
                  'displayName': widget.user.displayName,
                  'userPhotoUrl': widget.user.photoUrl
                }).then((onValue){
                  Navigator.pop(context);
                });
              });
            });
          },
        )
      ],
    );
  }

  Future _getImage() async {
    print('클릭 되나');
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }
}




