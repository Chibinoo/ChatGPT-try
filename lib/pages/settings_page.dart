import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<EntryProvider>(
          builder: (context, provider, _){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Storage Mode,',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Local Storage'),
                    Switch(
                      value: provider.useCloud,
                      onChanged: (value)async{
                        if(!value&&provider.useCloud){
                          //switch from cloud to local
                          bool? deleteCloud=await showDialog<bool>(
                            context: context,
                            builder: (ctx)=>AlertDialog(
                              title: const Text('Delete Cloud Data?'),
                              content: const Text(
                                'Do you want to delete your cloud data after syncing it ti local storage?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: ()=>Navigator.of(ctx).pop(true), 
                                  child: const Text('Delete Cloud Data')
                                )
                              ],
                            )
                          );
                          if(deleteCloud==null)return;//dissmissed
                          await provider.mergeCloudToLocal(deleteCloud);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(deleteCloud
                                ?'Cloud data merged and deleted'
                                :'Cloud data merged but kept online'
                              ),
                            ),
                          );
                        } else if(value&& !provider.useCloud){
                          //switching local to cloud
                          await provider.toggelStorage(true);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:Text('Local data merged to Cloud')),
                          );
                        }
                      }
                    ),
                    const Text('Cloud Storage'),
                  ],
                )
              ],
            );
          }
        ),
      )
    );
  }
}