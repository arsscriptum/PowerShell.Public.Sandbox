


using System;
using System.Text;
using System.Net;
using System.Net.Sockets;

namespace SimpleNet
{
	public static class NetServ {
		public static void StartServer(string ip, int port) {
			try {
				IPAddress ipAd = IPAddress.Parse(ip); //use local m/c IP address, and use the same in the client

		// Initializes the Listener 
				TcpListener myList=new TcpListener(ipAd,port);

		// Start Listeneting at the specified port 	
				myList.Start();
				
				Console.WriteLine("The server is running at port "  + port );
				Console.WriteLine("The local End point is  :" + myList.LocalEndpoint );
				Console.WriteLine("Waiting for a connection.....");
				
				Socket s=myList.AcceptSocket();
				Console.WriteLine("Connection accepted from "+s.RemoteEndPoint);
				
				byte[] b=new byte[100];
				int k=s.Receive(b);
				Console.WriteLine("Recieved...");
				for (int i=0;i<k;i++)
					Console.Write(Convert.ToChar(b[i]));

				ASCIIEncoding asen=new ASCIIEncoding();
				s.Send(asen.GetBytes("The string was recieved by the server."));
				Console.WriteLine("\nSent Acknowledgement");
				
				s.Close();
				myList.Stop();
					
			}
			catch (Exception e) {
				Console.WriteLine("Error..... " + e.StackTrace);
			}	
		}
	}
}