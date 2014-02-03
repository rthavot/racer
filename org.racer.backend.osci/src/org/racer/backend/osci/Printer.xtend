package org.racer.backend.osci

import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.IOException
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import java.util.List
import java.util.Map
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.Instance
import net.sf.orcc.df.Network
import net.sf.orcc.df.Port
import net.sf.orcc.util.OrccLogger
import net.sf.orcc.util.OrccUtil
import org.apache.commons.lang.ArrayUtils

class Printer {

	/**
	 * The algorithm used with MessageDigest. Can be MD, SHA, etc (see <a
	 * href="http://docs.oracle.com/javase/1.4.2/docs/guide/security/CryptoSpec.html#AppA">
	 * http://docs.oracle.com/javase/1.4.2/docs/guide/security/CryptoSpec.html#AppA</a>)
	 */
	private static val String digestAlgo = "MD5";

	protected var Map<String, Object> optionMap;
	protected var String entityName = "";
	protected var Map<Port, Connection> incomingPortMap
	protected var Map<Port, List<Connection>> outgoingPortMap

	new(Map<String, Object> options) {
		optionMap = options
	}

	//========================================
	//             Options
	//========================================
	def private setup(String name, Map<Port, Connection> incomings, Map<Port, List<Connection>> outgoings) {
		entityName = name
		incomingPortMap = incomings
		outgoingPortMap = outgoings
		optionMap.put("EntityName", name)
		optionMap.put("IncomingPortMap", incomings)
		optionMap.put("OutgoingPortMap", outgoings)
	}

	def getOptionMap() {
		return optionMap;
	}

	//========================================
	//             Compute Print
	//========================================
	def int print(String targetPath, Network network) {
		setup(network.name, null, null)
		val targetFile = new File(targetPath)
		OrccUtil::printFile(content(network), targetFile)
		return 0
	}

	def print(String targetPath, Actor actor) {
		setup(actor.name, actor.incomingPortMap, actor.outgoingPortMap)
		val targetFile = new File(targetPath)

		val content = content(actor);
		if (actor.native) {
			OrccLogger::noticeln(actor.name + " is native and not generated.")
		} else if (needToWriteFile(content, targetFile)) {
			OrccUtil::printFile(content, targetFile)
			return 0
		} else {
			return 1
		}
	}

	def print(String targetPath, Instance instance) {
		print(targetPath, instance.actor)
	}

	def protected content(Network network) ''''''

	def protected content(Actor actor) ''''''

	//========================================
	//             File protection
	//========================================	
	/**
	 * Return true if targetFile content need to be replaced by the content's
	 * value
	 * 
	 * @param targetFile
	 * @param content
	 */
	def protected needToWriteFile(CharSequence content, File target) {
		return ! target.exists() || ! MessageDigest::isEqual(hash(target), hash(content.toString.bytes));
	}

	/**
	 * Return the hash array for the byte[] content
	 * 
	 * @param content
	 * @return a byte[] containing the hash
	 */
	def private hash(byte[] content) {
		try {

			// MessageDigest is NOT thread safe, it must be created locally on
			// each call, it can't be a member of this class
			val messageDigest = MessageDigest::getInstance(digestAlgo);
			return messageDigest.digest(content);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return ArrayUtils::EMPTY_BYTE_ARRAY;
	}

	/**
	 * Return the hash array for the file
	 * 
	 * @param file
	 * @return a byte[] containing the hash
	 */
	def private hash(File file) {
		try {

			// MessageDigest is NOT thread safe, it must be created locally on
			// each call, it can't be a member of this class
			val messageDigest = MessageDigest::getInstance(digestAlgo);

			val in = new BufferedInputStream(new FileInputStream(file));
			var theByte = 0;
			try {
				while ((theByte = in.read()) != -1) {
					messageDigest.update(theByte as byte);
				}
			} catch (IOException e) {
				e.printStackTrace();
			} finally {
				in.close();
			}
			return messageDigest.digest();

		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return ArrayUtils::EMPTY_BYTE_ARRAY;
	}

}
