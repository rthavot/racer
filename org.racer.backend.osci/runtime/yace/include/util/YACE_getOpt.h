
#ifndef __UTILS_orcc_GetOpt_H__
#define __UTILS_orcc_GetOpt_H__

#include <string>
#include <sstream>
#include <vector>
#include <map>

#include <tinyxml.h>

typedef std::map<std::string, std::vector<std::string> > Tokens;
typedef std::map<std::string, std::vector<std::string> >::const_iterator TokensIterator;

namespace yace 
{
namespace util 
{

	template<typename T>
	inline void convert(const std::string& s, T& res)
	{
		std::stringstream ss(s);
		ss >> res;
		if (ss.fail() || !ss.eof())
		{
		}
	}

	/* specialization for bool */
	template <> 
	inline void convert(const std::string& s, bool& res)
	{
		if(s == "true")
		{
			res = true;
		} 
		else if(s == "false")
		{
			res = false;
		}
		else
		{
		}
	}

	/* specialization for std::string */
	template<>
	inline void convert(const std::string& s, std::string& res)
	{
		res = s;
	}

	template<typename T> class Options;

	class GetOpt
	{
	public:
		std::string input_file;
		//std::string design_file;
		TiXmlDocument design_file;

		void parse(int argc, char* argv[])
		{
			std::vector<std::string> currOptionValues;
			std::string optionName;
			for (int i = 1; i < argc; i++)
			{
				if (argv[i][0] == '-')
				{
					optionName = &argv[i][1];
				}
				else
				{
					tokens[optionName].push_back(&argv[i][0]);
				}
			}
		};

		template<typename T> T getOptionAs(const std::string&);

		const Tokens& getTokens() const {return tokens;};	

		void getOptions()
		{
			input_file = this->getOptionAs<std::string>("i");
			std::string d = this->getOptionAs<std::string>("d");
			if(!d.empty()){
				if(!design_file.LoadFile(d.c_str()))
				{
					printf( "Could not load the 'XDF' desing file.\n", design_file.ErrorDesc() );
				}
			}
		};
	private:
		Tokens tokens;

		template<typename T> class Options;
	};

	template<typename T>
	T GetOpt::getOptionAs(const std::string& s)
	{
		T res;
		Options<T>(this)(s, res);
		return res;
	}

	template<typename T>
	class GetOpt::Options
	{
	public:
		GetOpt::Options<T>(const GetOpt* options) : options(options) {}
	
		void operator()(const std::string& s, T& res)
		{
			TokensIterator it = options->getTokens().find(s);
			if(it != options->getTokens().end())
			{
				convert<T>((it->second)[0], res);
			}
		}

	private:
		const GetOpt* options;
	};

	template<typename T>
	class GetOpt::Options<std::vector<T> >
	{
	public:
		GetOpt::Options<std::vector<T>>(const GetOpt* options) : options(options) {}

		void operator () (const std::string& s, std::vector<T>& res)
		{
			Tokens tokens = options->getTokens();
			TokensIterator it = tokens.find(s);
			if(it != tokens.end())
			{
				std::vector<std::string> vec = it->second;
				std::vector<std::string>::iterator vec_it;
				for(vec_it = vec.begin(); vec_it != vec.end(); vec_it++)
				{
					T item;
					convert<T>(*vec_it, item);
					res.push_back(item);
				}
			}
			else
			{
				throw OptionNotFound();
			}
		}

	private:
		const GetOpt* options;

	};

	class OptionNotFound : public std::exception {};

	class OptionAsNoArg : public std::exception {};

	
}
}
#endif
