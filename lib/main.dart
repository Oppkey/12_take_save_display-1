import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panorama/panorama.dart';
import 'package:take_save_display_12/blocs/theta/theta_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThetaBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Colors.white,
        home: BlocBuilder<ThetaBloc, ThetaState>(
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black54,
                  title: const Text("THETA TSD"),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (state.finishedSaving ||
                                state.cameraState == 'initial') {
                              context.read<ThetaBloc>().add(PictureEvent());
                            } else {
                              const snackBar = SnackBar(
                                content: Text('Wait for Process to Complete'),
                                duration: Duration(seconds: 1),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.amber,
                          ),
                          iconSize: 80,
                        ),
                      ],
                    ),
                    state.cameraState == 'inProgress' && state.fileUrl.isEmpty
                        ? Column(
                            children: const [
                              CircularProgressIndicator(),
                              Text('Processing Photo'),
                            ],
                          )
                        : state.cameraState == 'done' &&
                                state.finishedSaving != true
                            ? Column(
                                children: const [
                                  CircularProgressIndicator(),
                                  Text('Saving to Gallery'),
                                ],
                              )
                            : Container(),
                    IconButton(
                        onPressed: () async {
                          final image = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image == null) return;
                          context
                              .read<ThetaBloc>()
                              .add(ImagePickerEvent(image));
                        },
                        icon: const Icon(Icons.image)),
                    state.images != null
                        ? ImageWidget(myFile: File(state.images!.path))
                        : Container()
                  ],
                ));
          },
        ),
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  final File myFile;
  const ImageWidget({Key? key, required this.myFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PanoramaWidget(myFile: myFile)));
            },
            child: Image.file(myFile)),
        const Icon(
          Icons.circle,
          color: Colors.black12,
          size: 65,
        ),
        InkWell(
            child: const Icon(
              Icons.threesixty,
              color: Colors.white,
              size: 50,
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PanoramaWidget(myFile: myFile))))
      ],
    );
  }
}

class PanoramaWidget extends StatelessWidget {
  final File myFile;
  const PanoramaWidget({Key? key, required this.myFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        Center(
          child: Panorama(
            animSpeed: 1.0,
            sensorControl: SensorControl.AbsoluteOrientation,
            child: Image.file(myFile),
          ),
        ),
        SizedBox(
          height: 80,
          width: 80,
          child: Image.network(
              'https://oppkey.com/wp-content/uploads/2022/01/oppkey_logo_300x300.jpg'),
        ),
      ]),
    );
  }
}
